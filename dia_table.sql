-- 1) USERS: 관리자 / 판매자 / 소비자 통합 관리
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(50) NOT NULL,
    role ENUM('ADMIN','SELLER','CUSTOMER') NOT NULL,
    phone VARCHAR(20),
    active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2) WORKSHOPS: 공방 정보
CREATE TABLE IF NOT EXISTS workshops (
    workshop_id INT AUTO_INCREMENT PRIMARY KEY,
    owner_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    address VARCHAR(255),
    contact_number VARCHAR(50),
    status ENUM('OPEN','CLOSED','HIDDEN') DEFAULT 'OPEN',
    approved ENUM('PENDING','APPROVED','REJECTED') DEFAULT 'PENDING',
    average_rating DECIMAL(3,2) DEFAULT 0.00,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 3) PROGRAMS: 공방 프로그램/클래스
CREATE TABLE IF NOT EXISTS programs (
    program_id INT AUTO_INCREMENT PRIMARY KEY,
    workshop_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(50),
    price INT NOT NULL,
    capacity INT NOT NULL,
    duration_min INT,
    difficulty ENUM('BEGINNER','INTERMEDIATE','ADVANCED'),
    thumb VARCHAR(255),
    folder VARCHAR(255),
    status ENUM('OPEN','CLOSED','CANCELLED') DEFAULT 'OPEN',
    schedule_type ENUM('ALWAYS','PERIOD') DEFAULT 'ALWAYS',
    period_start DATETIME,
    period_end DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (workshop_id) REFERENCES workshops(workshop_id) ON DELETE CASCADE
);

-- 4) SCHEDULES: 프로그램별 일정
CREATE TABLE IF NOT EXISTS schedules (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    program_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME,
    capacity INT NOT NULL,
    current_attendees INT DEFAULT 0,
    status ENUM('OPEN','CLOSED','CANCELLED') DEFAULT 'OPEN',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (program_id) REFERENCES programs(program_id) ON DELETE CASCADE
);

-- 5) RESERVATIONS: 예약 정보
CREATE TABLE IF NOT EXISTS reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    schedule_id INT NOT NULL,
    user_id INT NOT NULL,
    num_people INT DEFAULT 1,
    total_price INT NOT NULL,
    status ENUM('PENDING','PAID','CANCELLED','COMPLETED') DEFAULT 'PENDING',
    reserved_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (schedule_id) REFERENCES schedules(schedule_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 6) PAYMENTS: 결제 정보
CREATE TABLE IF NOT EXISTS payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    schedule_id INT NOT NULL,
    method ENUM('CARD','BANK','KAKAOPAY','NAVERPAY') NOT NULL,
    amount INT NOT NULL,
    status ENUM('SUCCESS','FAILED','REFUNDED') DEFAULT 'SUCCESS',
    paid_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (schedule_id) REFERENCES schedules(schedule_id) ON DELETE CASCADE
);

-- 7) REVIEWS: 사용자 후기
CREATE TABLE IF NOT EXISTS reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    program_id INT NOT NULL,
    rating INT NOT NULL,
    content TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    review_image VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (program_id) REFERENCES programs(program_id) ON DELETE CASCADE,
    CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5)
);

-- 8) FOLLOWS: 고객-공방 관계
CREATE TABLE IF NOT EXISTS follows (
    follow_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    workshop_id INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_user_workshop (user_id, workshop_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (workshop_id) REFERENCES workshops(workshop_id) ON DELETE CASCADE
);

-- 9) WISH_LIST: 위시리스트
CREATE TABLE IF NOT EXISTS wish_list (
    wish_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    program_id INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (program_id) REFERENCES programs(program_id) ON DELETE CASCADE
);

-- 10) ADMIN_QNA: 사용자/공방 → 관리자 문의
CREATE TABLE IF NOT EXISTS admin_qna (
    qna_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    admin_id INT,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    answer TEXT,
    status ENUM('PENDING','ANSWERED','CLOSED') DEFAULT 'PENDING',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    answered_at DATETIME,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (admin_id) REFERENCES users(user_id) ON DELETE SET NULL
);

-- 11) INQUIRY: 고객 → 공방 문의
CREATE TABLE IF NOT EXISTS inquiry (
    inquiry_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    program_id INT NOT NULL,
    title VARCHAR(100),
    content TEXT,
    status ENUM('WAITING','ANSWERED') DEFAULT 'WAITING',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (program_id) REFERENCES programs(program_id)
);

-- 12) WORKSHOP_PROFIT: 공방/프로그램별 수익 집계
CREATE TABLE IF NOT EXISTS workshop_profit (
    profit_id INT AUTO_INCREMENT PRIMARY KEY,
    workshop_id INT NOT NULL,
    program_id INT NOT NULL,
    total_amount INT NOT NULL,
    commission_rate DECIMAL(5,2) DEFAULT 0,
    commission_amt DECIMAL(12,2) GENERATED ALWAYS AS (total_amount * commission_rate / 100) STORED,
    paid_status ENUM('PAID','PENDING','REFUNDED','CANCELLED') DEFAULT 'PENDING',
    settled_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (workshop_id) REFERENCES workshops(workshop_id) ON DELETE CASCADE,
    FOREIGN KEY (program_id) REFERENCES programs(program_id) ON DELETE CASCADE
);

-- 13) NOTIFICATIONS: 알림 정보
CREATE TABLE IF NOT EXISTS notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT,
    target_type VARCHAR(100) NOT NULL,
    target_id INT,
    workshop_id INT,
    message TEXT NOT NULL,
    type VARCHAR(100) NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (target_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (workshop_id) REFERENCES workshops(workshop_id) ON DELETE SET NULL
);
