-- NutriTrack Database Schema (Dataset Version from Workbook1.xlsx)
-- 50 children | 24 parents | 3 BHWs | 1 Admin
-- Import this fresh into phpMyAdmin

CREATE DATABASE IF NOT EXISTS nutritrack_db;
USE nutritrack_db;

-- =============================================
-- TABLES
-- =============================================

CREATE TABLE users (
    id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    username VARCHAR(60) UNIQUE,
    role ENUM('parent','bhw','admin') NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE parents (
    user_id VARCHAR(20) PRIMARY KEY,
    birthday DATE,
    region VARCHAR(60),
    contact VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE bhws (
    user_id VARCHAR(20) PRIMARY KEY,
    employee_id VARCHAR(20),
    assigned_purok VARCHAR(60),
    contact VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE admins (
    user_id VARCHAR(20) PRIMARY KEY,
    department VARCHAR(60),
    contact VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE children (
    id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    age TINYINT NOT NULL,
    sex ENUM('Male','Female') DEFAULT 'Male',
    parent_id VARCHAR(20) NOT NULL,
    purok VARCHAR(60),
    bhw_id VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (bhw_id) REFERENCES users(id)
);

CREATE TABLE submissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    child_id VARCHAR(20) NOT NULL,
    height DECIMAL(5,2) NOT NULL,
    weight DECIMAL(5,2) NOT NULL,
    medical_condition TEXT,
    medication TEXT,
    dietary_intake TEXT,
    bmi DECIMAL(5,2),
    date_submitted DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (child_id) REFERENCES children(id) ON DELETE CASCADE
);

CREATE TABLE bhw_suggestions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    submission_id INT NOT NULL,
    bhw_id VARCHAR(20) NOT NULL,
    dietary_suggestion TEXT NOT NULL,
    intervention_plan TEXT,
    followup_date DATE,
    status ENUM('pending','approved','disapproved') DEFAULT 'pending',
    admin_feedback TEXT,
    admin_id VARCHAR(20),
    approved_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (submission_id) REFERENCES submissions(id) ON DELETE CASCADE,
    FOREIGN KEY (bhw_id) REFERENCES users(id),
    FOREIGN KEY (admin_id) REFERENCES users(id)
);

CREATE TABLE improvements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    child_id VARCHAR(20) NOT NULL,
    bhw_id VARCHAR(20),
    improvement_notes TEXT,
    weight_change DECIMAL(5,2),
    bmi_change DECIMAL(5,2),
    recorded_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (child_id) REFERENCES children(id) ON DELETE CASCADE,
    FOREIGN KEY (bhw_id) REFERENCES users(id)
);

-- =============================================
-- ADMIN
-- =============================================
INSERT INTO users (id, name, username, role, password) VALUES ('ADM-001', 'Admin User', 'admin', 'admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi');
INSERT INTO admins (user_id, department, contact) VALUES ('ADM-001', 'Barangay Health Department', '09123456789');

-- =============================================
-- BHWs (3 BHWs covering different puroks)
-- =============================================
INSERT INTO users (id, name, username, role, password) VALUES
('BHW-001', 'Nena Bautista', 'bhw1', 'bhw', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('BHW-002', 'Riza Salazar',  'bhw2', 'bhw', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('BHW-003', 'Luz Reyes',     'bhw3', 'bhw', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi');

INSERT INTO bhws (user_id, employee_id, assigned_purok, contact) VALUES
('BHW-001', 'EMP-001', 'Purok 1',      '09171111111'),
('BHW-002', 'EMP-002', 'Purok 2',      '09172222222'),
('BHW-003', 'EMP-003', 'Sitio Malaya', '09173333333');

-- =============================================
-- PARENTS (24 parents)
-- 6 with 3 children, 14 with 2 children, 4 with 1 child = 50 total
-- =============================================
INSERT INTO users (id, name, username, role, password) VALUES
('PAR-001', 'Maria Santos',       'parent1', 'parent', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('PAR-002', 'Jose Reyes',         'parent2', 'parent', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('PAR-003', 'Cora Dela Cruz',     'parent3', 'parent', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('PAR-004', 'Ramon Villanueva',   'parent4', 'parent', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('PAR-005', 'Lorna Castillo',     'parent5', 'parent', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('PAR-006', 'Eduardo Ramos',      'parent6', 'parent', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('PAR-007', 'Imelda Flores',      'parent7', 'parent', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('PAR-008', 'Danilo Mendoza',     'parent8', 'parent', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('PAR-009', 'Teresita Aquino',    'parent9', 'parent', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('PAR-010', 'Roberto Garcia',     'parent10', 'parent', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('PAR-011', 'Cecilia Torres',     'parent11', 'parent', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('PAR-012', 'Alfredo Navarro',    'parent12', 'parent', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('PAR-013', 'Gemma Espiritu',     'parent13', 'parent', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('PAR-014', 'Rodrigo Lim',        'parent14', 'parent', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('PAR-015', 'Norma Buenaventura', 'parent15', 'parent', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('PAR-016', 'Salvador Macaraeg',  'parent16', 'parent', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('PAR-017', 'Elvira Pangilinan',  'parent17', 'parent', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('PAR-018', 'Arturo Domingo',     'parent18', 'parent', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('PAR-019', 'Fe Ocampo',          'parent19', 'parent', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('PAR-020', 'Reynaldo Soriano',   'parent20', 'parent', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('PAR-021', 'Gloria Mercado',     'parent21', 'parent', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('PAR-022', 'Bernardo Tomas',     'parent22', 'parent', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('PAR-023', 'Anita Pascual',      'parent23', 'parent', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('PAR-024', 'Virgilio Medina',    'parent24', 'parent', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi');

INSERT INTO parents (user_id, birthday, region, contact) VALUES
('PAR-001', '1988-03-12', 'Purok 1',      '09151000001'),
('PAR-002', '1985-07-24', 'Purok 1',      '09151000002'),
('PAR-003', '1990-11-05', 'Purok 1',      '09151000003'),
('PAR-004', '1983-06-18', 'Purok 1',      '09151000004'),
('PAR-005', '1992-01-30', 'Purok 2',      '09151000005'),
('PAR-006', '1979-09-14', 'Purok 2',      '09151000006'),
('PAR-007', '1991-04-22', 'Purok 2',      '09151000007'),
('PAR-008', '1986-12-03', 'Purok 2',      '09151000008'),
('PAR-009', '1993-08-17', 'Purok 2',      '09151000009'),
('PAR-010', '1984-02-28', 'Purok 2',      '09151000010'),
('PAR-011', '1989-05-09', 'Purok 3',      '09151000011'),
('PAR-012', '1981-10-16', 'Purok 3',      '09151000012'),
('PAR-013', '1994-07-31', 'Purok 3',      '09151000013'),
('PAR-014', '1977-03-25', 'Purok 3',      '09151000014'),
('PAR-015', '1987-01-08', 'Purok 3',      '09151000015'),
('PAR-016', '1982-06-21', 'Purok 3',      '09151000016'),
('PAR-017', '1995-11-13', 'Sitio Malaya', '09151000017'),
('PAR-018', '1980-04-07', 'Sitio Malaya', '09151000018'),
('PAR-019', '1993-09-19', 'Sitio Malaya', '09151000019'),
('PAR-020', '1978-12-26', 'Sitio Malaya', '09151000020'),
('PAR-021', '1991-07-04', 'Sitio Malaya', '09151000021'),
('PAR-022', '1986-02-14', 'Sitio Malaya', '09151000022'),
('PAR-023', '1989-10-31', 'Purok 1',      '09151000023'),
('PAR-024', '1984-05-20', 'Purok 2',      '09151000024');

-- =============================================
-- CHILDREN (50 children mapped from dataset)
-- =============================================
INSERT INTO children (id, name, age, sex, parent_id, purok) VALUES
-- PAR-001 (Purok 1)
('C001', 'Ligaya Santos', 5, 'Female', 'PAR-001', 'Purok 1'),
('C002', 'Marco Santos', 5, 'Male', 'PAR-001', 'Purok 1'),
('C003', 'Danica Santos', 5, 'Female', 'PAR-001', 'Purok 1'),

-- PAR-002 (Purok 1)
('C004', 'Angela Reyes', 6, 'Female', 'PAR-002', 'Purok 1'),
('C005', 'Kenneth Reyes', 6, 'Male', 'PAR-002', 'Purok 1'),
('C006', 'Rina Reyes', 6, 'Male', 'PAR-002', 'Purok 1'),

-- PAR-003 (Purok 1)
('C007', 'Sophia Dela Cruz', 7, 'Female', 'PAR-003', 'Purok 1'),
('C008', 'Paulo Dela Cruz', 7, 'Male', 'PAR-003', 'Purok 1'),
('C009', 'Ella Dela Cruz', 7, 'Female', 'PAR-003', 'Purok 1'),

-- PAR-004 (Purok 1)
('C010', 'Justin Villanueva', 8, 'Male', 'PAR-004', 'Purok 1'),
('C011', 'Jasmine Villanueva', 8, 'Female', 'PAR-004', 'Purok 1'),
('C012', 'Carl Villanueva', 8, 'Male', 'PAR-004', 'Purok 1'),

-- PAR-005 (Purok 2)
('C013', 'Trisha Castillo', 8, 'Female', 'PAR-005', 'Purok 2'),
('C014', 'Lara Castillo', 7, 'Female', 'PAR-005', 'Purok 2'),
('C015', 'Bryan Castillo', 8, 'Male', 'PAR-005', 'Purok 2'),

-- PAR-006 (Purok 2)
('C016', 'Nathan Ramos', 9, 'Male', 'PAR-006', 'Purok 2'),
('C017', 'Ana Ramos', 9, 'Female', 'PAR-006', 'Purok 2'),
('C018', 'Luis Ramos', 9, 'Male', 'PAR-006', 'Purok 2'),

-- PAR-007 (Purok 2)
('C019', 'Camille Flores', 9, 'Female', 'PAR-007', 'Purok 2'),
('C020', 'Oliver Flores', 9, 'Male', 'PAR-007', 'Purok 2'),

-- PAR-008 (Purok 2)
('C021', 'Bea Mendoza', 9, 'Female', 'PAR-008', 'Purok 2'),
('C022', 'Jerome Mendoza', 9, 'Male', 'PAR-008', 'Purok 2'),

-- PAR-009 (Purok 2)
('C023', 'Lani Aquino', 9, 'Female', 'PAR-009', 'Purok 2'),
('C024', 'Rodel Aquino', 9, 'Male', 'PAR-009', 'Purok 2'),

-- PAR-010 (Purok 2)
('C025', 'Vince Garcia', 6, 'Female', 'PAR-010', 'Purok 2'),
('C026', 'Rafael Garcia', 10, 'Male', 'PAR-010', 'Purok 2'),

-- PAR-011 (Purok 3)
('C027', 'Pauline Torres', 10, 'Female', 'PAR-011', 'Purok 3'),
('C028', 'Mark Torres', 10, 'Male', 'PAR-011', 'Purok 3'),

-- PAR-012 (Purok 3)
('C029', 'Sheila Navarro', 11, 'Female', 'PAR-012', 'Purok 3'),
('C030', 'Nico Navarro', 11, 'Male', 'PAR-012', 'Purok 3'),

-- PAR-013 (Purok 3)
('C031', 'Abby Espiritu', 11, 'Female', 'PAR-013', 'Purok 3'),
('C032', 'Franz Espiritu', 11, 'Male', 'PAR-013', 'Purok 3'),

-- PAR-014 (Purok 3)
('C033', 'Hazel Lim', 12, 'Female', 'PAR-014', 'Purok 3'),
('C034', 'Kevin Lim', 12, 'Male', 'PAR-014', 'Purok 3'),

-- PAR-015 (Purok 3)
('C035', 'Rose Buenaventura', 12, 'Female', 'PAR-015', 'Purok 3'),
('C036', 'Jomar Buenaventura', 12, 'Male', 'PAR-015', 'Purok 3'),

-- PAR-016 (Purok 3)
('C037', 'Patricia Macaraeg', 13, 'Female', 'PAR-016', 'Purok 3'),
('C038', 'Dennis Macaraeg', 13, 'Male', 'PAR-016', 'Purok 3'),

-- PAR-017 (Sitio Malaya)
('C039', 'Michelle Pangilinan', 13, 'Female', 'PAR-017', 'Sitio Malaya'),
('C040', 'Ryan Pangilinan', 13, 'Male', 'PAR-017', 'Sitio Malaya'),

-- PAR-018 (Sitio Malaya)
('C041', 'Kristine Domingo', 14, 'Female', 'PAR-018', 'Sitio Malaya'),
('C042', 'Lance Domingo', 14, 'Male', 'PAR-018', 'Sitio Malaya'),

-- PAR-019 (Sitio Malaya)
('C043', 'Aileen Ocampo', 14, 'Female', 'PAR-019', 'Sitio Malaya'),
('C044', 'Ivan Ocampo', 14, 'Male', 'PAR-019', 'Sitio Malaya'),

-- PAR-020 (Sitio Malaya)
('C045', 'Vanessa Soriano', 15, 'Female', 'PAR-020', 'Sitio Malaya'),
('C046', 'Marlon Soriano', 15, 'Male', 'PAR-020', 'Sitio Malaya'),

-- PAR-021 (Sitio Malaya)
('C047', 'Celeste Mercado', 15, 'Female', 'PAR-021', 'Sitio Malaya'),

-- PAR-022 (Sitio Malaya)
('C048', 'Erwin Tomas', 15, 'Male', 'PAR-022', 'Sitio Malaya'),

-- PAR-023 (Purok 1)
('C049', 'Donna Pascual', 10, 'Female', 'PAR-023', 'Purok 1'),

-- PAR-024 (Purok 2)
('C050', 'Jeric Medina', 10, 'Male', 'PAR-024', 'Purok 2');

-- =============================================
-- SUBMISSIONS (1 per child, all data from Workbook1.xlsx)
-- height(cm), weight(kg), bmi values are exact from dataset
-- =============================================
INSERT INTO submissions (child_id, height, weight, medical_condition, medication, dietary_intake, bmi, date_submitted) VALUES
('C001', 105.0, 14.2, 'None',   'None',      'Rice, fish, vegetables',          12.88, '2026-04-01'),
('C002', 103.5, 13.1, 'None',   'None',      'Lugaw, milk, bread',              12.23, '2026-04-01'),
('C003', 102.0, 12.5, 'None',   'None',      'Milk, cereal, banana',            12.01, '2026-04-01'),
('C004', 110.0, 15.8, 'None',   'None',      'Rice, chicken, vegetables',       13.06, '2026-04-02'),
('C005', 112.0, 28.5, 'None',   'None',      'Fast food, rice, softdrinks',     22.72, '2026-04-02'),
('C006', 113.0, 30.0, 'None',   'None',      'Rice, pork, soda',                23.49, '2026-04-02'),
('C007', 116.0, 17.3, 'Asthma','Salbutamol', 'Rice, fish, malunggay soup',      12.86, '2026-04-03'),
('C008', 118.5, 32.0, 'None',   'None',      'Rice, fried chicken, juice',      22.79, '2026-04-03'),
('C009', 115.0, 16.5, 'None',   'None',      'Rice, vegetables, fish',          12.48, '2026-04-03'),
('C010', 122.0, 18.2, 'None',   'None',      'Rice, eggs, vegetables',          12.23, '2026-04-04'),
('C011', 124.0, 35.0, 'None',   'None',      'Rice, pork, chips, soda',         22.76, '2026-04-04'),
('C012', 124.5, 36.0, 'None',   'None',      'Rice, burger, fries, juice',      23.23, '2026-04-04'),
('C013', 123.0, 20.1, 'None',   'None',      'Rice, fish, kangkong',            13.29, '2026-04-05'),
('C014', 115.0, 16.5, 'None',   'None',      'Rice, vegetables, fish',          12.48, '2026-04-05'),
('C015', 125.0, 38.5, 'None',   'None',      'Rice, fried pork, softdrinks',    24.64, '2026-04-05'),
('C016', 128.0, 22.0, 'None',   'None',      'Rice, fish, ampalaya',            13.43, '2026-04-06'),
('C017', 130.0, 40.0, 'None',   'None',      'Rice, fast food, soda',           23.67, '2026-04-06'),
('C018', 131.0, 43.5, 'None',   'None',      'Rice, pork, chips',               25.35, '2026-04-06'),
('C019', 129.0, 23.5, 'None',   'None',      'Rice, fish, squash soup',         14.12, '2026-04-07'),
('C020', 130.5, 24.0, 'None',   'None',      'Rice, chicken, vegetables',       14.09, '2026-04-07'),
('C021', 127.0, 21.8, 'None',   'None',      'Rice, tinola soup, fruits',       13.52, '2026-04-07'),
('C022', 132.0, 44.0, 'None',   'None',      'Rice, liempo, soda',              25.25, '2026-04-07'),
('C023', 131.0, 25.0, 'None',   'None',      'Rice, fish, malunggay',           14.57, '2026-04-08'),
('C024', 133.0, 46.0, 'None',   'None',      'Rice, pork, chips, juice',        26.00, '2026-04-08'),
('C025', 111.0, 26.0, 'None',   'None',      'Rice, fried fish, soda',          21.10, '2026-04-08'),
('C026', 135.0, 27.0, 'None',   'None',      'Rice, vegetables, chicken',       14.81, '2026-04-09'),
('C027', 137.0, 48.0, 'None',   'None',      'Rice, fast food, softdrinks',     25.57, '2026-04-09'),
('C028', 138.0, 50.0, 'None',   'None',      'Rice, burger, fries, soda',       26.25, '2026-04-09'),
('C029', 140.0, 28.5, 'None',   'None',      'Rice, fish, green vegetables',    14.54, '2026-04-10'),
('C030', 143.0, 55.0, 'None',   'None',      'Rice, pork, soda, chips',         26.90, '2026-04-10'),
('C031', 142.0, 52.0, 'None',   'None',      'Rice, burger, juice, fries',      25.79, '2026-04-10'),
('C032', 141.0, 30.0, 'None',   'None',      'Rice, chicken, fruits',           15.09, '2026-04-11'),
('C033', 148.0, 58.0, 'None',   'None',      'Rice, fried food, soda',          26.48, '2026-04-11'),
('C034', 150.0, 62.0, 'None',   'None',      'Rice, pork, fast food, juice',    27.56, '2026-04-11'),
('C035', 147.0, 32.0, 'None',   'None',      'Rice, fish, vegetables',          14.81, '2026-04-12'),
('C036', 149.0, 33.0, 'None',   'None',      'Rice, mongo, fruits',             14.86, '2026-04-12'),
('C037', 154.0, 65.0, 'None',   'None',      'Rice, liempo, soda, chips',       27.41, '2026-04-12'),
('C038', 157.0, 68.0, 'None',   'None',      'Rice, burger, fries, soda',       27.59, '2026-04-13'),
('C039', 153.0, 35.0, 'None',   'None',      'Rice, fish, malunggay soup',      14.95, '2026-04-13'),
('C040', 155.0, 34.0, 'None',   'None',      'Rice, vegetables, fish',          14.15, '2026-04-13'),
('C041', 159.0, 70.0, 'None',   'None',      'Rice, fried chicken, soda',       27.69, '2026-04-14'),
('C042', 162.0, 72.0, 'None',   'None',      'Rice, pork, fast food',           27.43, '2026-04-14'),
('C043', 158.0, 37.0, 'None',   'None',      'Rice, fish, vegetables, fruits',  14.82, '2026-04-14'),
('C044', 160.0, 36.0, 'None',   'None',      'Rice, chicken, mongo soup',       14.06, '2026-04-15'),
('C045', 162.0, 74.0, 'None',   'None',      'Rice, liempo, chips, soda',       28.20, '2026-04-15'),
('C046', 166.0, 78.0, 'None',   'None',      'Rice, pork, fast food, juice',    28.31, '2026-04-15'),
('C047', 161.0, 39.0, 'None',   'None',      'Rice, fish, green vegetables',    15.05, '2026-04-16'),
('C048', 164.0, 38.0, 'None',   'None',      'Rice, mongo, vegetables',         14.13, '2026-04-16'),
('C049', 136.0, 49.0, 'None',   'None',      'Rice, burger, fries, soda',       26.49, '2026-04-16'),
('C050', 134.0, 26.5, 'None',   'None',      'Rice, chicken, fruits',           14.76, '2026-04-16');

-- =============================================
-- BHW SUGGESTIONS (obese/overweight children)
-- submission IDs match the order above (1=C001, 5=C005, etc.)
-- =============================================
INSERT INTO bhw_suggestions (submission_id, bhw_id, dietary_suggestion, intervention_plan, status, admin_feedback, admin_id, approved_at) VALUES
(5,  'BHW-001', 'Reduce softdrinks and fast food. Increase fruits and vegetables. Serve smaller rice portions.', 'Weekly monitoring at health center. Encourage active play outdoors.', 'approved', NULL, 'ADM-001', NOW()),
(6,  'BHW-001', 'Replace soda with water or fresh juice. Add more vegetables. Avoid fatty pork cuts.', 'Biweekly weight check. Provide nutrition counseling to parents.', 'approved', NULL, 'ADM-001', NOW()),
(8,  'BHW-001', 'Limit fried chicken and sweetened drinks. Encourage home-cooked meals with vegetables.', 'Monthly BMI tracking. Enroll child in after-school physical activity.', 'approved', NULL, 'ADM-001', NOW()),
(11, 'BHW-002', 'Avoid chips and soda. Replace snacks with fresh fruits and water. Reduce rice by 1/4 cup.', 'Weekly check-in. Discuss portion control with parents.', 'approved', NULL, 'ADM-001', NOW()),
(12, 'BHW-002', 'Eliminate fast food. Switch to home meals with vegetables and lean protein.', 'Biweekly weight monitoring. Encourage 30 min walk daily.', 'pending', NULL, NULL, NULL),
(15, 'BHW-002', 'Reduce pork and softdrinks. Add malunggay and squash. Limit rice to 1 cup per meal.', 'Monthly check. Provide sample meal plan to parents.', 'pending', NULL, NULL, NULL),
(17, 'BHW-003', 'Stop fast food consumption. Introduce balanced meals: rice, vegetables, fish, fruits.', 'Weekly nutrition counseling. Refer to rural health unit if no improvement in 4 weeks.', 'approved', NULL, 'ADM-001', NOW()),
(18, 'BHW-003', 'Eliminate chips and soda. Increase water intake. Serve fruits as snacks.', 'Biweekly monitoring. Discuss importance of balanced diet with family.', 'disapproved', 'Please include specific portion sizes in the suggestion.', 'ADM-001', NULL),
(22, 'BHW-003', 'Reduce liempo and high-fat foods. Replace soda with water. Add green vegetables daily.', 'Monthly check. Encourage physical activity after school hours.', 'approved', NULL, 'ADM-001', NOW()),
(24, 'BHW-001', 'Limit chips and high-sugar juice. Increase vegetable and fish intake. Reduce rice to 1 cup.', 'Weekly weight check. Provide printed meal guide to parents.', 'pending', NULL, NULL, NULL),
(25, 'BHW-001', 'Reduce fried fish and soda. Add fresh fruits, malunggay soup, and vegetables daily.', 'Biweekly monitoring. Teach parents healthy food substitutions.', 'approved', NULL, 'ADM-001', NOW()),
(27, 'BHW-002', 'Avoid fast food and softdrinks. Introduce more vegetables and whole grains. Limit rice to 1 cup.', 'Monthly BMI check. Encourage family walks and outdoor activities.', 'approved', NULL, 'ADM-001', NOW()),
(28, 'BHW-002', 'Eliminate burger and fries. Serve home-cooked meals: fish, vegetables, rice in moderation.', 'Weekly monitoring. Refer to nutritionist if no improvement in 1 month.', 'pending', NULL, NULL, NULL),
(30, 'BHW-003', 'Replace chips and soda with fruits and water. Reduce pork. Add kangkong, malunggay, squash.', 'Monthly check. Engage parents in barangay nutrition seminar.', 'approved', NULL, 'ADM-001', NOW()),
(31, 'BHW-003', 'Reduce burger and fries. Increase vegetable and fruit servings. Limit sweetened juice.', 'Biweekly weight monitoring. Encourage participation in school sports.', 'pending', NULL, NULL, NULL),
(33, 'BHW-001', 'Stop fried food habit. Shift to grilled or boiled meals. Add ampalaya, squash, and fruits.', 'Monthly check. Conduct cooking demo for parents on healthy food preparation.', 'approved', NULL, 'ADM-001', NOW()),
(34, 'BHW-001', 'Eliminate fast food. Switch to home meals with lean meat, vegetables, and fruits.', 'Weekly monitoring. Coordinate with school for nutrition program participation.', 'pending', NULL, NULL, NULL),
(37, 'BHW-002', 'Reduce liempo and chips. Increase fish and vegetable intake. Replace soda with water.', 'Monthly BMI tracking. Counsel parents on long-term obesity risks.', 'approved', NULL, 'ADM-001', NOW()),
(38, 'BHW-002', 'Limit burger and fries. Encourage rice alternatives like sweet potato or cassava.', 'Biweekly weight check. Enroll in school nutrition awareness program.', 'pending', NULL, NULL, NULL),
(41, 'BHW-003', 'Reduce fried chicken and soda. Introduce salads, fruits, and fish into daily meals.', 'Monthly check. Provide printed healthy lifestyle guide to parent.', 'approved', NULL, 'ADM-001', NOW()),
(42, 'BHW-003', 'Eliminate fast food and pork fat. Shift to fish, vegetables, and boiled dishes.', 'Weekly monitoring. Refer to rural health unit for further assessment.', 'pending', NULL, NULL, NULL),
(45, 'BHW-001', 'Reduce liempo, chips, and soda. Serve more vegetables, fruits, and lean protein daily.', 'Monthly BMI check. Discuss risk of obesity complications with parents.', 'approved', NULL, 'ADM-001', NOW()),
(46, 'BHW-001', 'Replace fast food with home-cooked meals. Limit pork. Add fruits and vegetables daily.', 'Biweekly weight monitoring. Encourage 30-minute daily exercise.', 'pending', NULL, NULL, NULL),
(49, 'BHW-002', 'Avoid burger and fries. Replace soda with water. Add fish, green vegetables, and fruits.', 'Monthly monitoring. Conduct parent nutrition counseling session.', 'approved', NULL, 'ADM-001', NOW());

-- =============================================
-- IMPROVEMENTS (children showing progress)
-- =============================================
INSERT INTO improvements (child_id, bhw_id, improvement_notes, weight_change, bmi_change, recorded_date) VALUES
('C005', 'BHW-001', 'Parent reported reduced soda intake. Child started eating more vegetables.',    -0.50, -0.32, '2026-04-22'),
('C006', 'BHW-001', 'Visible improvement in eating habits. Less pork in diet.',                      -0.30, -0.20, '2026-04-22'),
('C008', 'BHW-001', 'Child now brings home-cooked lunch to school. Weight slightly reduced.',        -0.40, -0.27, '2026-04-23'),
('C011', 'BHW-002', 'Parent following meal plan. Snacks replaced with fresh fruits.',                -0.60, -0.38, '2026-04-23'),
('C017', 'BHW-003', 'Fast food consumption stopped per parent report. BMI improving steadily.',      -0.80, -0.50, '2026-04-24'),
('C022', 'BHW-003', 'Soda replaced with water. Green vegetables added to daily meals.',              -0.50, -0.30, '2026-04-24'),
('C025', 'BHW-001', 'Dietary changes followed by family. Child more active outdoors.',               -0.40, -0.29, '2026-04-25'),
('C027', 'BHW-002', 'Fast food reduced significantly. Child joined school sports club.',             -0.70, -0.38, '2026-04-25'),
('C030', 'BHW-003', 'Chips and soda eliminated. Family now cooks with malunggay regularly.',         -0.90, -0.50, '2026-04-26'),
('C033', 'BHW-001', 'Shift to grilled meals noted. Parent attended cooking demonstration.',          -1.00, -0.46, '2026-04-26'),
('C037', 'BHW-002', 'Liempo replaced with fish 4x per week. Water intake increased significantly.',  -0.80, -0.35, '2026-04-27'),
('C041', 'BHW-003', 'Fried food consumption greatly reduced. Salads introduced to diet.',            -1.20, -0.46, '2026-04-27'),
('C045', 'BHW-001', 'Parent very cooperative. Child now eats 3 servings of vegetables daily.',       -1.50, -0.57, '2026-04-28'),
('C049', 'BHW-002', 'No more fast food reported. Child drinks only water and fresh juice now.',      -0.60, -0.32, '2026-04-28');
