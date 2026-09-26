# 🧠 Session Learnings & Reusable Engineering Patterns (IDOP-CCBA-WAY)

> **Mục đích**: Lưu trữ các kinh nghiệm lập trình, bẫy lỗi (pitfalls), và giải pháp đã được chứng minh qua thực tế triển khai các module IDOP.  
> **Quy định**: Agent BẮT BUỘC đọc file này khi khởi động Planning Mode hoặc SDLC Loop theo quy định tại `.agents/AGENTS.md`.

---

## 1. 🔐 Xác Thực Chứng Chỉ App-Only PKCS#12 (.pfx)
- **Vấn đề**: File chứng chỉ Microsoft 365 trên Linux là file nhị phân PKCS#12 (`.pfx`), tuyệt đối không được đọc dưới dạng text file PEM (`open(..., 'r')`).
- **SSOT**: Luôn tái sử dụng `tools.auth.graph_auth.get_graph_client()` hoặc `tools.auth.graph_auth.load_pfx_credentials()`.
- **Mẫu chuẩn**:
  ```python
  from tools.auth.graph_auth import get_graph_client
  client = get_graph_client(client_id=..., tenant_id=..., cert_path=..., cert_password=...)
  ```

---

## 2. 🔄 Vòng Đời Microsoft Graph Delta Queries & Phục Hồi HTTP 410 Gone
- **Delta Link Checkpoints**: Lưu checkpoint `@odata.deltaLink` bền vững vào bảng SQLite `system_checkpoints`.
- **Xử lý Xóa (`@removed`)**: Bản ghi xóa trong Graph Delta không có `fields`. Phải nhận diện cờ `@removed` để phát sinh sự kiện `DELETED` mà không gọi validate fields.
- **Phục hồi HTTP 410 Gone (Delta Token Expired)**:
  ```python
  if resp.status_code == 410:
      self.clear_checkpoint(site_id, list_name)
      url = f"https://graph.microsoft.com/v1.0/sites/{site_id}/lists/{list_name}/items/delta?$expand=fields"
      resp = await self.graph.request("GET", url)
  ```

---

## 3. 🛡️ Pydantic v2 Ingestion Guard & Định Tuyến DLQ
- **Merge ID ở Root Level**: Graph Delta để `id` ở root object, không nằm trong `item["fields"]`. Khi validate vào model Pydantic v2 (`SharePointItem`), bắt buộc merge ID:
  ```python
  payload_to_validate = dict(fields)
  if "ID" not in payload_to_validate and "id" not in payload_to_validate and item_id:
      payload_to_validate["ID"] = item_id
  ```
- **Bọc Schema Validation**: Không bao giờ để `ValidationError` làm sập chu trình sync:
  ```python
  try:
      validated = ModelClass.model_validate(payload_to_validate)
  except ValidationError as val_err:
      self.dlq.record_failure(..., error_code="VALIDATION_ERROR", error_message=str(val_err))
      continue
  ```

---

## 4. 🔁 Gán Trực Tiếp Authorization Header trong HTTP Retry Loops
- **Anti-pattern**: Dùng `headers.setdefault("Authorization", f"Bearer {token}")` trong vòng lặp retry có thể nuốt chửng token mới nếu token bị refresh giữa các attempt.
- **Pattern chuẩn**:
  ```python
  headers = dict(kwargs.get("headers") or {})
  headers["Authorization"] = f"Bearer {token}"
  headers.setdefault("Accept", "application/json")
  kwargs["headers"] = headers
  ```

---

## 5. 🚦 Phân Định Lỗi HTTP: Transport Retries vs Application Handling
- **Chỉ Retry**: `429 Too Many Requests` (tuân thủ `Retry-After`) và `500, 502, 503, 504 Server Errors`.
- **Không Retry ở tầng HTTP**: Các lỗi nghiệp vụ `400, 404, 410, 412` phải trả về ngay cho tầng gọi:
  ```python
  if response.status_code not in (429, 500, 502, 503, 504):
      return response
  ```

---

## 6. 🔒 Chống Thundering Herd Khi Refresh Token Đồng Thời
- Sử dụng `async with self._lock:` khi kiểm tra và lấy token mới từ MSAL:
  ```python
  async with self._lock:
      now = time.time()
      if self._access_token and (self._token_expires_at - now) > 300.0:
          return self._access_token
      # Chỉ 1 coroutine thực hiện acquire_token_for_client
  ```

---

## 7. ⏰ Chuẩn Hóa Timezone UTC-Aware cho HTTP 429 Retry-After
- Header `Retry-After` dạng RFC 2822 HTTP-Date khi parse qua `email.utils.parsedate_to_datetime()` có thể trả về naive datetime:
  ```python
  target_dt = email.utils.parsedate_to_datetime(cleaned)
  if target_dt.tzinfo is None:
      target_dt = target_dt.replace(tzinfo=timezone.utc)
  diff = (target_dt - datetime.now(timezone.utc)).total_seconds()
  ```

---

## 8. 🔂 Triệt Tiêu Tiếng Vọng 3 Tầng (LoopBreaker) & Băm Tất Định
- **Tier 1 (Author App ID)**: Bỏ qua item nếu `lastModifiedBy.application.id == spark_client_id`.
- **Tier 2 (LRU eTag Cache)**: Cache các eTag do chính Spark cập nhật trong 15 phút.
- **Tier 3 (SHA-256 Payload Hash)**: Bắt buộc dùng `json.dumps(payload, sort_keys=True)` để đảm bảo tính tất định trên mọi hệ điều hành.

---

## 9. 🗄️ Quản Trị Kết Nối SQLite An Toàn Trong Daemon
- Phân biệt rõ kết nối `:memory:` (dùng chung trong test) và file database thật:
  - Với `:memory:`: Giữ kết nối mở, chỉ quản lý transaction commit/rollback.
  - Với file database thật: Luôn đóng connection trong khối `finally` để tránh rò rỉ file descriptors khi chạy daemon lâu ngày.

---

## 10. 🧹 Vệ Sinh Repo & Tiêu Chuẩn Mypy Monorepo
- Mọi database SQLite, cache, DLQ lưu tại `tools/output/state/` (được bảo vệ bởi `.gitignore`).
- Khi đóng GitHub Issue / PR, luôn tháo nhãn `in-progress` để giải phóng Peer Claim Lock.
- Lệnh kiểm tra static typing chuẩn:
  ```bash
  python -m mypy --explicit-package-bases --ignore-missing-imports tools/
  ```
