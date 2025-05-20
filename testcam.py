import cv2

# آدرس RTSP دوربین
rtsp_url = "rtsp://admin:@192.168.1.168:80/ch0_0.264"

# ایجاد شیء VideoCapture برای اتصال به دوربین
cap = cv2.VideoCapture(rtsp_url)

# چک کردن اینکه اتصال موفق بوده یا نه
if not cap.isOpened():
    print("خطا در اتصال به دوربین")
    exit()

# حلقه برای نمایش جریان ویدیو
while True:
    ret, frame = cap.read()
    if not ret:
        print("خطا در خوندن فریم")
        break
    
    # نمایش فریم در پنجره
    cv2.imshow('Camera Stream', frame)
    
    # برای خروج، کلید 'q' رو فشار بده
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# آزاد کردن منابع و بستن پنجره‌ها
cap.release()
cv2.destroyAllWindows()