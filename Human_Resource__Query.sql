--HUMAN RESOURCES
-- Create 'departments' table
CREATE TABLE departments (
    id  SERIAL PRIMARY KEY,
    name VARCHAR(50),
    manager_id INT
);

--Inserting values into the department table
INSERT INTO departments (name, manager_id)
VALUES ('HR', 1), 
	   ('IT', 2), 
	   ('Sales', 3);

--Viewing the department table
SELECT *
FROM departments;

-- Create 'employees' table
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    hire_date DATE,
    job_title VARCHAR(50),
    department_id INT REFERENCES departments(id)
);

--Inserting values into the employees table
INSERT INTO employees (name, hire_date, job_title, department_id)
VALUES ('John Doe', '2018-06-20', 'HR Manager', 1),
       ('Jane Smith', '2019-07-15', 'IT Manager', 2),
       ('Alice Johnson', '2020-01-10', 'Sales Manager', 3),
       ('Bob Miller', '2021-04-30', 'HR Associate', 1),
       ('Charlie Brown', '2022-10-01', 'IT Associate', 2),
       ('Dave Davis', '2023-03-15', 'Sales Associate', 3);

--Viewing the employees table
SELECT *
FROM employees;

-- Create 'projects' table
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    start_date DATE,
    end_date DATE,
    department_id INT REFERENCES departments(id)
);



-- Insert data into 'projects'
INSERT INTO projects (name, start_date, end_date, department_id)
VALUES ('HR Project 1', '2023-01-01', '2023-06-30', 1),
       ('IT Project 1', '2023-02-01', '2023-07-31', 2),
       ('Sales Project 1', '2023-03-01', '2023-08-31', 3);
	   
--Viewing the projects table
SELECT *
FROM projects;

--Updating departments table
UPDATE departments
SET manager_id = (SELECT id FROM employees WHERE name = 'John Doe')
WHERE name = 'HR';

--Updating departments table
UPDATE departments
SET manager_id = (SELECT id FROM employees WHERE name = 'Jane Smith')
WHERE name = 'IT';

--Updating departments table
UPDATE departments
SET manager_id = (SELECT id FROM employees WHERE name = 'Alice Johnson')
WHERE name = 'Sales';


--Answers to questions
--QUESTION ONE:Find the longest ongoing project for each department.
SELECT departments.name AS department_name,
       projects.start_date AS project_start_date,
	   projects.end_date AS project_end_date,
	   projects.end_date - projects.start_date AS project_duration
	   FROM projects
INNER JOIN departments
ON projects.department_id = departments.id
ORDER BY 4 DESC;

--QUESTION TWO:Find all employees who are not managers.
SELECT employees.name AS employee
FROM employees
LEFT JOIN departments
ON employees.id = departments.manager_id
WHERE departments.manager_id IS NULL; 

--QUESTION THREE:Find all employees who have been hired after the start of a project in their department.
SELECT employees.name AS employees,
       departments.name AS department,
       projects.start_date AS start_date,
	   employees.hire_date AS hire_date
FROM employees 
INNER JOIN projects
ON  employees.department_id = projects.department_id
INNER JOIN departments 
ON departments.id = projects.department_id
WHERE employees.hire_date > projects.start_date
GROUP BY 1,2,3,4;

--QUESTION FOUR:Rank employees within each department based on their hire date (earliest hire gets the highest rank).
SELECT employees.name AS employee_name,
       departments.name AS department,
       employees.hire_date,
	   RANK() OVER (PARTITION BY departments.name ORDER BY employees.hire_date ASC) AS employee_rank
FROM employees
INNER JOIN departments
ON employees.department_id = departments.id
GROUP BY 1,2,3;

--QUESTION FIVE:Find the duration between the hire date of each employee and the hire date of the next employee hired in the same department.
--Creating a cte to house the employee, next hired and thier date respectively
WITH cte AS (
			SELECT employees.name AS employee_name,
	 			   departments.name AS department,
				   employees.hire_date,
				   LEAD(employees.name,1) OVER (PARTITION BY departments.name) AS next_hired_employee,
	               LEAD(employees.hire_date) OVER (PARTITION BY departments.name) AS next_employee_hired_date
       		FROM employees
	        INNER JOIN departments
	        ON employees.department_id = departments.id
	        )			
--Now, answering the question
SELECT cte.department,
	   cte.employee_name,
       cte.hire_date,
	   cte.next_hired_employee,
	   cte.next_employee_hired_date,
	   cte.next_employee_hired_date - cte.hire_date AS days_to_next_hired
FROM cte
WHERE next_employee_hired_date IS NOT NULL;		