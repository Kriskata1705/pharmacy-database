drop database if exists pharmacy_system;
create database pharmacy_system;
use pharmacy_system;

-- klienti
create table customers(
	customer_id int auto_increment primary key,
    first_name varchar(50) not null,
    last_name varchar(50) not null,
    egn char(10) not null unique,
    phone varchar(20),
    email varchar(100),
    birth_date date,
    address varchar(255),
    loyalty_card_number varchar(30) unique,
    loyalty_points int not null default 0,
    created_at datetime not null default current_timestamp
);

-- farmacevti
create table pharmacists(
	pharmacist_id int auto_increment primary key,
    first_name varchar(50) not null,
    last_name varchar(50) not null,
    license_number varchar(50) not null unique,
    phone varchar(20),
    email varchar(100),
    hire_date date,
    salary decimal(10,2),
    created_at datetime not null default current_timestamp
);

-- lekari
create table doctors(
	doctor_id int auto_increment primary key,
    first_name varchar(50) not null,
    last_name varchar(50) not null,
    specialty varchar(100),
    license_number varchar(50) not null unique,
    phone varchar(20),
    email varchar(100),
    created_at datetime	not null default current_timestamp
);

-- dostavchici
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    bulstat VARCHAR(20) NOT NULL UNIQUE,
    phone varchar(20),
    email varchar(100),
    address varchar(255),
    created_at datetime not null default current_timestamp
);

-- proizvoditeli
create table manufacturers(
	manufacturer_id int auto_increment primary key,
    name varchar(100) not null unique,
    country varchar(100),
    phone varchar(50),
    email varchar(100),
    created_at datetime not null default current_timestamp
);

-- categorii lekarstva
create table categories(
	category_id int auto_increment primary key,
    name varchar(100) not null unique,
    description varchar(255)
);

-- forma na lekarstovo
create table dosage_forms(
	dosage_form_id int auto_increment primary key,
    name varchar(100) not null unique,
    description varchar(255)
);

-- bolest/sustoqnie
create table diseases(
	disease_id int auto_increment primary key,
    name varchar(100) not null unique,
    description varchar(255)
);

-- sustavki
create table active_ingredients(
	ingredient_id int auto_increment primary key,
    name varchar(100) not null unique,
    description varchar(255)
);

-- lekarstva
create table medicines(
	medicine_id int auto_increment primary key,
    name varchar(100) not null,
    manufacturer_id int not null,
    category_id int not null,
    dosage_form_id int not null,
    description text,
    standard_dosage varchar(255),
    usage_instructions text,
    unit_price decimal(10,2) not null,
    requires_prescription boolean not null default false,
    min_age int default 0,
    is_active boolean not null default true,
    created_at datetime not null default current_timestamp,
    constraint fk_medicines_manufacturer 
    foreign key(manufacturer_id) references manufacturers(manufacturer_id),
    constraint fk_medicines_category 
    foreign key(category_id) references categories(category_id),
    constraint fk_medicines_dosage_form
    foreign key(dosage_form_id) references dosage_forms(dosage_form_id),
    constraint chk_medicines_price
    check(unit_price > 0),
    constraint chk_medicines_min_age
    check(min_age >=0)
);

-- lekarstva - bolesti
create table medicine_diseases(
	medicine_id int not null,
    disease_id int not null,
    primary key(medicine_id, disease_id),
    constraint fk_medicine_diseases_medicine
    foreign key(medicine_id) references medicines(medicine_id),
    constraint fk_medicine_diseases_disease
    foreign key(disease_id) references diseases(disease_id)
);

-- lekarstva - aktivni sustavki
create table medicine_ingredients(
	medicine_id int not null,
    ingredient_id int not null,
    amount decimal(10,2) not null,
    unit varchar(20) not null,
    primary key(medicine_id, ingredient_id),
    constraint fk_medicine_ingredients_medicine
    foreign key (medicine_id) references medicines(medicine_id),
    constraint fk_medicine_ingredients_ingredient
    foreign key (ingredient_id) references active_ingredients(ingredient_id),
    constraint chk_medicine_ingredients_amount
    check(amount > 0)
);

-- preduprejdeniq
create table medicine_warnings(
	warning_id int auto_increment primary key,
    medicine_id int not null,
    warning_text varchar(255) not null,
    severity_level enum('low', 'medium', 'high') not null default 'medium',
    constraint fk_medicine_warnings_medicine 
    foreign key (medicine_id) references medicines(medicine_id)
);

-- recepti
create table prescriptions(
	prescription_id int auto_increment primary key,
    customer_id int not null,
    doctor_id int not null,
    issue_date date not null,
    valid_until date not null,
    status enum('active', 'partially_used', 'used', 'expired', 'cancelled') not null default 'active',
    notes varchar(255),
    created_at datetime not null default current_timestamp,
    constraint fk_prescriptions_customer
    foreign key(customer_id) references customers(customer_id),
    constraint fk_prescriptions_doctor
    foreign key(doctor_id) references doctors(doctor_id),
    constraint chk_prescriptions_dates
    check (valid_until >= issue_date)
);

-- redove v receptata
create table prescription_items(
	prescription_item_id int auto_increment primary key,
    prescription_id int not null,
    medicine_id int not null,
    quantity_prescribed int not null,
    dosage_text varchar(255),
    duration_days int,
    constraint fk_prescription_items_prescription
    foreign key (prescription_id) references prescriptions(prescription_id),
    constraint fk_prescription_items_medicine
    foreign key (medicine_id) references medicines(medicine_id),
    constraint chk_prescription_items_quantity
    check (quantity_prescribed > 0),
    constraint chk_prescription_items_duration
    check (duration_days is null or duration_days > 0)
);

-- prodajbi
create table sales(
	sale_id int auto_increment primary key,
    customer_id int not null,
    pharmacist_id int not null,
    sale_datetime datetime not null default current_timestamp,
    total_amount decimal(10,2) not null default 0.00,
    notes varchar(250),
    created_at datetime not null default current_timestamp,
    constraint fk_sales_customer
    foreign key (customer_id) references customers(customer_id),
    constraint fk_sales_pharmacist
    foreign key (pharmacist_id) references pharmacists(pharmacist_id),
    constraint chk_sales_total_amount
    check (total_amount >= 0)
);

-- partidi
create table batches(
	batch_id int auto_increment primary key,
    medicine_id int not null,
    supplier_id int not null,
    batch_number varchar(50) not null unique,
    received_date date not null,
    expiry_date date not null,
    purchase_price decimal(10,2) not null,
    sale_price decimal(10,2) not null,
    quantity_in_stock int not null default 0,
    minimum_stock int not null default 0,
    
    constraint fk_batches_medicine
	foreign key(medicine_id) references medicines(medicine_id),
    
    constraint fk_batches_supplier
    foreign key(supplier_id) references suppliers(supplier_id),
    
    constraint chk_batches_dates
    check (expiry_date >= received_date),
    
    constraint chk_batches_price
    check (sale_price > 0),
    
    constraint chk_batches_quantity
    check (quantity_in_stock >= 0),
    
    constraint chk_batches_minimum_stock
    check (minimum_stock >= 0)
);

-- redove v prodajbata
create table sale_items(
	sale_item_id int auto_increment primary key,
    sale_id int not null,
    medicine_id int not null,
    batch_id int not null,
    prescription_id int null,
    quantity int not null,
    unit_price decimal(10,2) not null,
    line_total decimal(10,2) not null,
    constraint fk_sale_items_sale
    foreign key (sale_id) references sales(sale_id),
    
    constraint fk_sale_items_medicine
    foreign key (medicine_id) references medicines(medicine_id),
    
    constraint fk_sale_items_batch
    foreign key (batch_id) references batches(batch_id),
    
    constraint fk_sale_items_prescription
    foreign key (prescription_id) references prescriptions(prescription_id),
    
    constraint chk_sale_items_quantity
    check (quantity > 0),
    
    constraint chk_sale_items_unit_price
    check (unit_price > 0.00),
    
    constraint chk_sale_items_line_total
    check(line_total > 0)
);


-- plashtaniq
create table payments(
	payment_id int auto_increment primary key,
    sale_id int not null,
    payment_date datetime not null default current_timestamp,
    payment_method enum('cash', 'card', 'bank_transfer') not null,
    paid_amount decimal(10,2) not null,
    reference_number varchar(100),
    
    constraint fk_payments_sale
    foreign key (sale_id) references sales(sale_id),
    
    constraint chk_payments_paid_amount
    check (paid_amount > 0.00)
);

-- istoriq na cenite
create table price_history(
	price_history_id int auto_increment primary key,
    medicine_id int not null,
    old_price decimal(10,2) not null,
    new_price decimal(10,2) not null,
    changed_at datetime not null default current_timestamp,
    
    constraint fk_price_history_medicine
    foreign key (medicine_id) references medicines(medicine_id),
    
    constraint chk_price_history_old_price
    check (old_price > 0),
    
    constraint chk_price_history_new_price
    check (new_price > 0)
);

-- namalenie
create table discounts(
	discount_id int auto_increment primary key,
    name varchar(100) not null,
    discount_percent decimal(5,2) not null,
    start_date date not null,
    end_date date not null,
    is_active boolean not null default true,
    
    constraint chk_discounts_percent
    check(discount_percent > 0 and discount_percent <= 100),
    
    constraint chk_discounts_dates
    check (end_date >= start_date)
);

-- dvijenie v sklada
create table stock_movements (
    movement_id int auto_increment primary key,
    batch_id int not null,
    movement_type enum('IN', 'OUT', 'ADJUSTMENT') not null,
    quantity int not null,
    movement_date datetime not null default current_timestamp,
    notes varchar(255),

    constraint fk_stock_movements_batch
	foreign key (batch_id) references batches(batch_id),

    constraint chk_stock_movements_quantity
	check (quantity > 0)
);
alter table sales
add column discount_id int null,
add constraint fk_sales_discount
	foreign key(discount_id) references discounts(discount_id);

insert into customers (first_name, last_name, egn, phone, email, birth_date, address, loyalty_card_number, loyalty_points) values
('Ivan', 'Petrov', '9001011234', '0888123456', 'ivan.petrov@email.com', '1990-01-01', 'Sofia, Mladost 1', 'LC1001', 120),
('Maria', 'Georgieva', '9202152345', '0888234567', 'maria.georgieva@email.com', '1992-02-15', 'Plovdiv, Trakia', 'LC1002', 80),
('Georgi', 'Dimitrov', '8507203456', '0888345678', 'georgi.dimitrov@email.com', '1985-07-20', 'Varna, Center', 'LC1003', 200),
('Elena', 'Stoyanova', '9705114567', '0888456789', 'elena.stoyanova@email.com', '1997-05-11', 'Burgas, Lazur', 'LC1004', 50),
('Petar', 'Nikolov', '8809305678', '0888567890', 'petar.nikolov@email.com', '1988-09-30', 'Ruse, Druzhba', 'LC1005', 30);

insert into pharmacists (first_name, last_name, license_number, phone, email, hire_date, salary) values
('Nikolay', 'Ivanov', 'PH1001', '0899123456', 'nikolay.ivanov@pharmacy.bg', '2022-03-01', 2200.00),
('Desislava', 'Koleva', 'PH1002', '0899234567', 'desislava.koleva@pharmacy.bg', '2021-06-15', 2400.00),
('Radoslav', 'Petkov', 'PH1003', '0899345678', 'radoslav.petkov@pharmacy.bg', '2023-01-10', 2100.00);

insert into doctors(first_name, last_name, specialty, license_number, phone, email) values
('Hristo', 'Marinov', 'General Practitioner', 'DR1001', '0877123456', 'hristo.marinov@hospital.bg'),
('Teodora', 'Ilieva', 'Pediatrics', 'DR1002', '0877234567', 'teodora.ilieva@hospital.bg'),
('Stefan', 'Angelov', 'Pulmonology', 'DR1003', '0877345678', 'stefan.angelov@hospital.bg');

insert into manufacturers(name, country, phone, email) values
('Sopharma', 'Bulgaria', '021111111', 'office@sopharma.bg'),
('Bayer', 'Germany', '021222222', 'contact@bayer.com'),
('Pfizer', 'USA', '021333333', 'support@pfizer.com'),
('Novartis', 'Switzerland', '021444444', 'info@novartis.com'),
('GlaxoSmithKline', 'UK', '021555555', 'office@gsk.com');

insert into suppliers(name, bulstat, phone, email, address) values
('Pharma Supply Ltd', '123456789', '029111111', 'sales@pharmasupply.bg', 'Sofia, Industrial Zone'),
('Med Logistics AD', '234567891', '029222222', 'office@medlogistics.bg', 'Plovdiv, Maritsa'),
('Health Trade OOD', '345678912', '029333333', 'contact@healthtrade.bg', 'Varna, West Zone');

insert into categories(name, description) values
('Antibiotics', 'Medicines used to treat bacterial infections'),
('Painkillers', 'Medicines for pain relief'),
('Anti-inflammatory', 'Medicines reducing inflammation'),
('Vitamins', 'Vitamin supplements'),
('Cough Medicines', 'Medicines for cough and cold symptoms');

insert into dosage_forms(name, description) values
('Tablets', 'Solid oral dosage form'),
('Capsules', 'Medicine enclosed in capsule shell'),
('Syrup', 'Liquid oral dosage form'),
('Cream', 'Topical semi-solid dosage form'),
('Ampoules', 'Injectable dosage form');

insert into diseases(name, description) values 
('Flu', 'Viral respiratory infection'),
('Cold', 'Common cold'),
('Headache', 'Pain in the head region'),
('Bronchitis', 'Inflammation of the bronchial tubes'),
('Vitamin Deficiency', 'Lack of essential vitamins');

insert into active_ingredients(name, description) values
('Paracetamol', 'Pain reliever and fever reducer'),
('Ibuprofen', 'Nonsteroidal anti-inflammatory drug'),
('Amoxicillin', 'Penicillin antibiotic'),
('Dextromethorphan', 'Cough suppressant'),
('Vitamin C', 'Essential vitamin');

insert into medicines(name, manufacturer_id, category_id, dosage_form_id, description, standard_dosage, usage_instructions, unit_price, requires_prescription, min_age, is_active) values
('Paracetamol 500mg', 1, 2, 1, 'Pain relief and fever reduction', '1 tablet 3 times daily', 'Take after food with water', 4.50, FALSE, 6, TRUE),
('Ibuprofen 200mg', 2, 3, 1, 'Anti-inflammatory and pain relief', '1 tablet 2-3 times daily', 'Take after meals', 6.80, FALSE, 12, TRUE),
('Amoxicillin 500mg', 3, 1, 2, 'Antibiotic for bacterial infections', '1 capsule 3 times daily', 'Use only as prescribed by doctor', 12.90, TRUE, 0, TRUE),
('Cough Syrup Kids', 4, 5, 3, 'Syrup for dry cough', '5 ml 3 times daily', 'Shake well before use', 8.20, FALSE, 3, TRUE),
('Vitamin C 1000mg', 5, 4, 1, 'Vitamin C supplement', '1 tablet daily', 'Dissolve in water or take directly', 9.50, FALSE, 0, TRUE);

insert into medicine_diseases(medicine_id, disease_id) values
(1, 1),
(1, 3),
(2, 3),
(2, 4),
(3, 4),
(4, 2),
(4, 4),
(5, 5),
(5, 1);

insert into medicine_ingredients(medicine_id, ingredient_id, amount, unit) values
(1, 1, 500.00, 'mg'),
(2, 2, 200.00, 'mg'),
(3, 3, 500.00, 'mg'),
(4, 4, 15.00, 'mg'),
(5, 5, 1000.00, 'mg');

insert into medicine_warnings(medicine_id, warning_text, severity_level) values
(1, 'Do not exceed the recommended daily dose', 'medium'),
(2, 'Not suitable for people with stomach ulcers', 'high'),
(3, 'Use only with valid prescription', 'high'),
(4, 'Not suitable for children under 3 years', 'medium'),
(5, 'Consult a doctor if taken with other supplements', 'low');

insert into prescriptions(customer_id, doctor_id, issue_date, valid_until, status, notes) values
(1, 1, '2026-03-01', '2026-03-31', 'active', 'Prescription for bronchitis treatment'),
(2, 2, '2026-03-05', '2026-04-05', 'active', 'Child treatment prescription'),
(3, 3, '2026-02-20', '2026-03-20', 'expired', 'Old prescription'),
(4, 1, '2026-03-10', '2026-04-10', 'partially_used', 'Antibiotic treatment'),
(5, 3, '2026-03-12', '2026-04-12', 'active', 'Respiratory infection');

insert into prescription_items(prescription_id, medicine_id, quantity_prescribed, dosage_text, duration_days) values
(1, 3, 2, '1 capsule 3 times daily', 7),
(2, 4, 1, '5 ml 3 times daily', 5),
(3, 3, 1, '1 capsule 3 times daily', 5),
(4, 3, 2, '1 capsule 2 times daily', 10),
(5, 3, 1, '1 capsule 3 times daily', 6);

insert into batches(medicine_id, supplier_id, batch_number, received_date, expiry_date, purchase_price, sale_price, quantity_in_stock, minimum_stock) values
(1, 1, 'BATCH-PAR-001', '2026-01-10', '2027-01-10', 2.50, 4.50, 100, 20),
(2, 1, 'BATCH-IBU-001', '2026-01-12', '2027-01-12', 4.20, 6.80, 80, 15),
(3, 2, 'BATCH-AMO-001', '2026-02-01', '2026-12-01', 8.50, 12.90, 50, 10),
(4, 3, 'BATCH-COU-001', '2026-02-15', '2026-10-15', 5.30, 8.20, 60, 12),
(5, 2, 'BATCH-VIT-001', '2026-01-20', '2027-01-20', 6.50, 9.50, 90, 20);

insert into sales(customer_id, pharmacist_id, sale_datetime, total_amount, notes) values
(1, 1, '2026-03-15 10:30:00', 17.40, 'Regular purchase'),
(2, 2, '2026-03-16 12:15:00', 8.20, 'Cough syrup purchase'),
(3, 1, '2026-03-17 15:40:00', 19.00, 'Vitamin and painkiller purchase'),
(4, 3, '2026-03-18 09:20:00', 12.90, 'Prescription medicine'),
(5, 2, '2026-03-18 17:10:00', 4.50, 'Single item purchase');

insert into sale_items(sale_id, medicine_id, batch_id, prescription_id, quantity, unit_price, line_total) values
(1, 1, 1, NULL, 2, 4.50, 9.00),
(1, 2, 2, NULL, 1, 6.80, 6.80),
(1, 5, 5, NULL, 1, 1.60, 1.60),
(2, 4, 4, 2, 1, 8.20, 8.20),
(3, 5, 5, NULL, 2, 9.50, 19.00),
(4, 3, 3, 4, 1, 12.90, 12.90),
(5, 1, 1, NULL, 1, 4.50, 4.50);

insert into payments(sale_id, payment_date, payment_method, paid_amount, reference_number) values
(1, '2026-03-15 10:31:00', 'card', 17.40, 'CARD-1001'),
(2, '2026-03-16 12:16:00', 'cash', 8.20, 'CASH-1002'),
(3, '2026-03-17 15:41:00', 'card', 19.00, 'CARD-1003'),
(4, '2026-03-18 09:21:00', 'bank_transfer', 12.90, 'BANK-1004'),
(5, '2026-03-18 17:11:00', 'cash', 4.50, 'CASH-1005');

insert into price_history(medicine_id, old_price, new_price, changed_at) values
(1, 4.00, 4.50, '2026-01-05 09:00:00'),
(2, 6.20, 6.80, '2026-01-10 10:00:00'),
(3, 11.50, 12.90, '2026-02-01 11:00:00'),
(4, 7.80, 8.20, '2026-02-10 12:00:00'),
(5, 8.90, 9.50, '2026-01-15 13:00:00');

insert into discounts(name, discount_percent, start_date, end_date, is_active) values
('Spring Promo', 10.00, '2026-03-01', '2026-03-31', TRUE),
('Vitamin Week', 15.00, '2026-03-10', '2026-03-20', TRUE),
('Loyal Customer Discount', 5.00, '2026-01-01', '2026-12-31', TRUE);

update sales 
set discount_id = 1
where sale_id = 1;

update sales
set discount_id = 2
where sale_id = 3;

insert into stock_movements(batch_id, movement_type, quantity, movement_date, notes) values
(1, 'IN', 100, '2026-01-10 08:00:00', 'Initial stock delivery'),
(2, 'IN', 80, '2026-01-12 09:00:00', 'Initial stock delivery'),
(3, 'IN', 50, '2026-02-01 10:00:00', 'Initial stock delivery'),
(4, 'IN', 60, '2026-02-15 11:00:00', 'Initial stock delivery'),
(5, 'IN', 90, '2026-01-20 12:00:00', 'Initial stock delivery'),
(1, 'OUT', 2, '2026-03-15 10:31:00', 'Sale item from sale 1'),
(2, 'OUT', 1, '2026-03-15 10:31:00', 'Sale item from sale 1'),
(5, 'OUT', 1, '2026-03-15 10:31:00', 'Sale item from sale 1'),
(4, 'OUT', 1, '2026-03-16 12:16:00', 'Sale item from sale 2'),
(5, 'OUT', 2, '2026-03-17 15:41:00', 'Sale item from sale 3'),
(3, 'OUT', 1, '2026-03-18 09:21:00', 'Sale item from sale 4'),
(1, 'OUT', 1, '2026-03-18 17:11:00', 'Sale item from sale 5');


-- zaqvki

-- 2. vsichki lekarstva s recepta i na 10 euro
select medicine_id, name, unit_price, requires_prescription
from medicines
where requires_prescription = true and unit_price > 10;

-- 3. kolko prodajbi ima vseki farmacevt
select p.pharmacist_id, p.first_name, p.last_name, count(s.sale_id) as total_sales
from pharmacists p
join sales s
on p.pharmacist_id = s.pharmacist_id 
group by p.pharmacist_id, p.first_name, p.last_name;

-- 4. vsqka prodajba s klienta i farmacevta, koito q e obrabotil
select 
	s.sale_id, 
    s.sale_datetime, 
    c.first_name as customer_first_name, 
    c.last_name as customer_last_name, 
    p.first_name as pharmacist_first_name,
    p.last_name as pharmacist_last_name,
    s.total_amount
from sales s
inner join customers c 
on s.customer_id = c.customer_id
inner join pharmacists p
on s.pharmacist_id = p.pharmacist_id;

-- 5. vsichki lekarstva dori i tezi koito oshte ne sa prodavani
select 
    m.medicine_id,
    m.name,
    count(si.sale_item_id) as times_sold
from medicines m
left join sale_items si
on m.medicine_id = si.medicine_id
group by m.medicine_id, m.name;

-- 6. lekarstvata chiqto cena e po visoka ot srednata na vsichki
select medicine_id, name, unit_price
from medicines
where unit_price > (
	select avg(unit_price)
    from medicines
);

-- 7. obshtiq prihod ot vsqko lekarstvo
select m.medicine_id,m.name, sum(si.line_total) as total_revenue
from sale_items si
join medicines m on si.medicine_id = m.medicine_id
group by m.medicine_id, m.name
order by total_revenue desc;

-- prodajbi po metod na plashtane
select payment_method, sum(paid_amount) as total_paid
from payments
group by payment_method;

-- lekarstva i sustavkite im
select m.name as medicine_name, ai.name as ingredient_name,
mi.amount, mi.unit
from medicine_ingredients mi
join medicines m on mi.medicine_id = m.medicine_id
join active_ingredients ai on mi.ingredient_id = ai.ingredient_id;


-- trigeri

-- proverqva dali kolichestvoto e nalichno, dali sroka ne e iztekal, dali kearstvoto ot sale_items suvpada s lek. ot izbranata partida, dali ima recepta ako lekarstvoto e s recepta
drop trigger if exists trg_before_insert_sale_items;
delimiter $$
create trigger trg_before_insert_sale_items
before insert on sale_items
for each row
begin
	declare v_stock int;
    declare v_expiry date;
    declare v_batch_medicine_id int;
    declare v_requires_prescription boolean;
    
    select quantity_in_stock, expiry_date, medicine_id
    into v_stock, v_expiry, v_batch_medicine_id
    from batches
    where batch_id = new.batch_id;
    
    if v_batch_medicine_id <> new.medicine_id then
		signal sqlstate '45000'
        set message_text = 'Batch does not belong to the selected medicine';
	end if;
    
    if v_stock < new.quantity then
		signal sqlstate '45000'
        set message_text = 'Not enough stock in batch';
	end if;
    
    if v_expiry < curdate() then
		signal sqlstate	'45000'
        set message_text = 'Expired batch!!!';
	end if;
    
    select requires_prescription
    into v_requires_prescription
    from medicines
    where medicine_id = new.medicine_id;
    
    if v_requires_prescription = true and new.prescription_id is null then 
		signal sqlstate '45000'
        set message_text = 'Prescription is required!';
	end if;
    
    set new.line_total = new.quantity * new.unit_price;
end$$
delimiter ;


-- namalqva nalichnostta, zapis v skladovi dvi, preizdhislqva sumata na prodajbata
drop trigger if exists trg_after_insert_sale_items;
delimiter $$
create trigger trg_after_insert_sale_items
after insert on sale_items
for each row
begin
	update batches
    set quantity_in_stock = quantity_in_stock - new.quantity
    where batch_id = new.batch_id;
    
    insert into stock_movements(batch_id, movement_type, quantity, movement_date, notes) values
    (new.batch_id,'OUT', new.quantity, now(), concat('Automatic stock movement for sale_id = ', new.sale_id));
    
    update sales
    set total_amount = (
		select ifnull(sum(line_total), 0)
        from sale_items
        where sale_id = new.sale_id
    )
    where sale_id = new.sale_id;
end$$
delimiter ;

-- preizchislqva line_total, ako se promeni kolichestvoto ili cena
drop trigger if exists trg_before_update_sale_items;
delimiter $$
create trigger trg_before_update_sale_items
before update on sale_items
for each row
begin
	set new.line_total = new.quantity * new.unit_price;
end$$
delimiter ;

-- preizchislqva total_amount v sales sled promqna na red v prodajba
drop trigger if exists trg_after_update_sale_items
delimiter $$
create trigger trg_after_update_sale_items
after update on sale_items
for each row
begin
	update sales
    set total_amount = (
		select ifnull(sum(line_total), 0)
        from sale_items
        where sale_id = new.sale_id
    )
    where sale_id = new.sale_id;
end$$
delimiter ;

-- preizchiclqva total_amount v sales ako byde iztrit red ot prodajbata
drop trigger if exists trg_after_delete_sale_items;
delimiter $$
create trigger trg_after_delete_sale_items
after delete on sale_items
for each row
begin
	update sales
    set total_amount = (
		select ifnull(sum(line_total), 0)
        from sale_items
        where sale_id = old.sale_id
    )
    where sale_id = old.sale_id;
end$$
delimiter ;

-- zapisva avtomatichno vsqka promqna na cenata v price_history
drop trigger if exists trg_after_update_medicines_price
delimiter $$
create trigger trg_after_update_medicines_price
after update on medicines
for each row
begin
	if old.unit_price <> new.unit_price then
		insert into price_history(medicine_id, old_price, new_price, changed_at)
        values(new.medicine_id, old.unit_price, new.unit_price, now());
	end if;
end $$
delimiter ;















