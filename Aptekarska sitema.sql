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





