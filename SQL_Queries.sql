-- Questions:
-- 1.	Write a query to display the current salary for each employee in department 300. Assume that only current employees are kept in the system, and therefore the most current salary for each employee is the entry in the salary history with a NULL end date. Sort the output in descending order by salary amount.

-- update salary_history set sal_end = null where sal_end like '%2099%';
-- select * from salary_history;

select e.emp_num,e.emp_fname,e.emp_lname,e.dept_num,s.sal_amount as current_salary
from employee e,salary_history s 
where e.dept_num = '300' 
	and e.emp_num = s.emp_num
	and s.sal_end is null
order by s.sal_amount desc;



-- 
-- 2.	Write a query to display the starting salary for each employee. The starting salary would be the entry in the salary history with the oldest salary start date for each employee. Sort the output by employee number.
-- 

select e.emp_num,e.emp_fname,e.emp_lname,s.sal_amount as starting_salary
from employee e,salary_history s	
where e.emp_num = s.emp_num
	and (e.emp_num,s.sal_from) in 
			(select sh.emp_num,min(sh.sal_from)
		 	from salary_history sh	
		 	group by sh.emp_num
        	);
	
	
	
-- 3.	Write a query to display the invoice number, line numbers, product SKUs, product descriptions, and brand ID for sales of sealer and top coat products of the same brand on the same invoice. 
-- 

select sealer.inv_num,sealer.line_num,sealer.prod_sku,sealer.prod_descript,sealer.brand_id
from 
	(select l1.inv_num,l1.line_num,l1.prod_sku,p1.prod_descript,p1.brand_id 
	from line l1,product p1
	where l1.prod_sku=p1.prod_sku
		and p1.prod_category = 'Sealer'
	 ) sealer,	
	(select l2.inv_num,l2.line_num,l2.prod_sku,p2.prod_descript,p2.brand_id 
	from line l2,product p2
	where l2.prod_sku=p2.prod_sku
		and p2.prod_category = 'Top Coat'
	 ) top_coat
where sealer.inv_num = top_coat.inv_num 
	and sealer.brand_id = top_coat.brand_id
;
	 
select e1.emp_num,e1.emp_fname,e1.emp_lname,e1.emp_email,sum(l1.line_qty) as Quantity_Sold
	from employee e1,invoice i1,line l1,product p1,brand b1
	where e1.emp_num = i1.employee_id
		and i1.inv_num = l1.inv_num
		and p1.prod_sku = l1.prod_sku
		and p1.brand_id = b1.brand_id
		and b1.brand_name = 'BINDER PRIME'
	 group by e1.emp_num,e1.emp_fname,e1.emp_lname,e1.emp_email
     having sum(l1.line_qty) = 
     	(
		select max(a.Quantity_Sold) from 
			(select e.emp_num,sum(l.line_qty) as Quantity_Sold
			from employee e,invoice i,line l,product p,brand b
			where e.emp_num = i.employee_id
				and i.inv_num = l.inv_num
				and p.prod_sku = l.prod_sku
				and p.brand_id = b.brand_id
				and b.brand_name = 'BINDER PRIME'
	 		group by e.emp_num
	 		) a
	 	 )
order by e1.emp_lname;

	        	


                	
-- 4.	The Binder Prime Company wants to recognize the employee who sold the most of their products during a specified period. Write a query to display the employee number, employee first name, employee last name, e-mail address, and total units sold for the employee who sold the most Binder Prime brand products between November 1, 2015, and December 5, 2015. If there is a tie for most units sold, sort the output by employee last name. 


select e1.emp_num,e1.emp_fname,e1.emp_lname,e1.emp_email,sum(l1.line_qty) as Quantity_Sold
	from employee e1,invoice i1,line l1,product p1,brand b1
	where e1.emp_num = i1.employee_id
		and i1.inv_num = l1.inv_num
		and p1.prod_sku = l1.prod_sku
		and p1.brand_id = b1.brand_id
		and b1.brand_name = 'BINDER PRIME'
	    and i1.inv_date between '2015-11-01' and '2015-12-05'
	 group by e1.emp_num,e1.emp_fname,e1.emp_lname,e1.emp_email
     having sum(l1.line_qty) = 
     	(
		select max(a.Quantity_Sold) from 
			(select e.emp_num,sum(l.line_qty) as Quantity_Sold
			from employee e,invoice i,line l,product p,brand b
			where e.emp_num = i.employee_id
				and i.inv_num = l.inv_num
				and p.prod_sku = l.prod_sku
				and p.brand_id = b.brand_id
				and b.brand_name = 'BINDER PRIME'
	     	    and i.inv_date between '2015-11-01' and '2015-12-05'
	 		group by e.emp_num
	 		) a
	 	 )
order by e1.emp_lname;
	

-- 
-- 5.	Write a query to display the customer code, first name, and last name of all customers who have had at least one invoice completed by employee 83649 and at least one invoice completed by employee 83677. Sort the output by customer last name and then first name. 
-- 

select c1.cust_code,c1.cust_fname,c1.cust_lname from customer c1,invoice i1
where i1.employee_id=83649 
	and c1.cust_code=i1.cust_code
    and exists 
    	(select (1)
    	 from customer c2,invoice i2
		 where i2.employee_id=83677 
			and c2.cust_code=i2.cust_code
			and c1.cust_code=c2.cust_code
         )
order by c1.cust_lname,c1.cust_fname;


-- 6.	LargeCo is planning a new promotion in Alabama (AL) and wants to know about the largest purchases made by customers in that state. Write a query to display the customer code, customer first name, last name, full address, invoice date, and invoice total of the largest purchase made by each customer in Alabama. Be certain to include any customers in Alabama who have never made a purchase (their invoice dates should be NULL and the invoice totals should display as 0). 
-- 

select c.cust_code,c.cust_fname,c.cust_lname,concat(c.cust_street,' ',c.cust_state,' ',cust_zip) address,
	   i.inv_date,IFNULL(i.inv_total,0) largest_purchase
from customer c left outer join invoice i 
	on c.cust_code = i.cust_code
	where (c.cust_code,i.inv_total) in  
			(
			select c1.cust_code,max(i1.inv_total)
			from customer c1 left outer join invoice i1 
			on c1.cust_code = i1.cust_code
			where c1.cust_state = 'AL'
			group by c1.cust_code
			)
		or (i.inv_total is null and c.cust_state = 'AL');



-- 7.	One of the purchasing managers is interested in the impact of product prices on the sale of products of each brand. Write a query to display the brand name, brand type, average price of products of each brand, and total units sold of products of each brand. Even if a product has been sold more than once, its price should only be included once in the calculation of the average price. However, you must be careful because multiple products of the same brand can have the same price, and each of those products must be included in the calculation of the brand's average price.
-- 

select qty.brand_name,qty.brand_type,price.avg_price,qty.total_units_sold 
from
	(
	select b.brand_id,b.brand_name,b.brand_type,sum(l.line_qty) total_units_sold from brand b,product p,line l
	where b.brand_id=p.brand_id
		and p.prod_sku=l.prod_sku
	group by b.brand_id
	) qty,
	(
	select b.brand_id,avg(p.prod_price) avg_price 
	from brand b,product p
	where b.brand_id=p.brand_id
	group by b.brand_id
	) price
where qty.brand_id = price.brand_id;
		
		
-- 8.	The purchasing manager is still concerned about the impact of price on sales. Write a query to display the brand name, brand type, product SKU, product description, and price of any products that are not a premium brand, but that cost more than the most expensive premium brand products.
-- 
select * from brand;
select b.brand_id,b.brand_name,b.brand_type,p.prod_sku,p.prod_descript,p.prod_price 
from brand b,product p
where b.brand_id=p.brand_id
	and b.brand_type <> 'PREMIUM'
	and p.prod_price > any 
							(
							select max(p1.prod_price) 
						 	from product p1,brand b1 
						 	where p1.brand_id = b1.brand_id 
						 		and b1.brand_type = 'PREMIUM'
							group by b1.brand_id
							);



-- 9.	Using SQL descriptive statistics functions calculate the value of the following items: 
-- a.	What are the products that have a price greater than $50?

select p.prod_sku,p.prod_descript,p.prod_price 
from product p where p.prod_price > 50;

							
-- b.	What is total value of our entire inventory on hand?

select sum(p.prod_price*p.prod_qoh) on_hand_tot from product p;

-- c.	How many customers do we presently have and what is the total of all customer balances?

select count(c.cust_code) cust_tot,sum(c.cust_balance) cust_tot_bal from customer c ;

-- d.	What are to top three states that buy the most product in dollars from the company?
-- 

select c.cust_state,sum(i.inv_total) from  invoice i,customer c
where c.cust_code = i.cust_code
group by c.cust_state 
order by 2 desc
limit 3;


-- 10.	Using predictive statistics calculate what the predicted forecast of sales for the next year based on the INV_DATE (independent) and INV_TOTAL (dependent).  Remember that you will need to convert the INV_DATE from the MS SQL Server stored date value to the expect Julian date, since numbers in MS SQL are stored as the number of days since 1/1/1900 with the fraction as the portion of a day (if you are using a different DBMS use the appropriate code for conversion.)
-- declare @d1 datetime
-- 
-- set @d1 = 41867
-- 
-- select @d1
-- 
-- select CONVERT(varchar(20),@d1,120)
-- 
-- or if you want to do it in one statement:
-- select CONVERT(varchar(25),cast(41867 as datetime),120)
-- 
-- Analyze your results from the linear regression, and provide the R2, model, coefficients, and the confidence interval for your analysis. 
 
select year(inv_date) year,monthname(inv_date) monthname,month(inv_date) month ,sum(inv_total) inv_total from invoice
group by year(inv_date),monthname(inv_date),month(inv_date)
order by 1,3;

select inv_date,sum(inv_total) inv_total from invoice
group by inv_date
order by 1;


