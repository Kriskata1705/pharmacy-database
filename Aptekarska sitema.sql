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
    diseases_id int not null,
    primary key(medicine_id, diseases_id),
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







