#1.список клиентов с непрерывной историей за год, то есть каждый месяц на регулярной основе без пропусков за указанный годовой период, 
#средний чек за период с 01.06.2015 по 01.06.2016, средняя сумма покупок за месяц, количество всех операций по клиенту за период;


SELECT c.Id_client,
COUNT(t.Id_check) AS total_operations,
AVG(t.Sum_payment) AS avg_check,
SUM(t.Sum_payment)/12 AS avg_monthly_sum
FROM customer c
JOIN transactions t 
ON c.Id_client = t.ID_client
WHERE t.date_new 
BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY c.Id_client
HAVING
COUNT(DISTINCT DATE_FORMAT(t.date_new, '%Y-%m')) = 13;


#2. Информацию в разрезе месяцев:
#средняя сумма чека в месяц;
#среднее количество операций в месяц;
#среднее количество клиентов, которые совершали операции;
#долю от общего количества операций за год и долю в месяц от общей суммы операций;
#вывести % соотношение M/F/NA в каждом месяце с их долей затрат;


SELECT DATE_FORMAT(t.date_new, '%Y-%m') AS month,
ROUND(SUM(t.Sum_payment)/COUNT(t.Id_check),2) AS avg_sum_per_check,
ROUND(COUNT(t.Id_check)/COUNT(DISTINCT t.ID_client),2) AS avg_ops_per_client,
COUNT(DISTINCT t.ID_client) AS clients_count,
ROUND(COUNT(t.Id_check) / (SELECT COUNT(*) FROM transactions) * 100,2) AS month_ops_percent,
ROUND(SUM(t.Sum_payment) / (SELECT SUM(Sum_payment) FROM transactions) * 100,2) AS month_sum_percent,
CONCAT(
'M: ', ROUND(SUM(CASE WHEN c.Gender='M' THEN t.Sum_payment ELSE 0 END)/SUM(t.Sum_payment)*100,2), '% / ',
'F: ', ROUND(SUM(CASE WHEN c.Gender='F' THEN t.Sum_payment ELSE 0 END)/SUM(t.Sum_payment)*100,2), '% / ',
'NA: ', ROUND(SUM(CASE WHEN c.Gender='NA' OR c.Gender IS NULL THEN t.Sum_payment ELSE 0 END)/SUM(t.Sum_payment)*100,2), '%'
) AS gender_sum_percent
FROM transactions t
LEFT JOIN customer c ON t.ID_client = c.Id_client
GROUP BY month
ORDER BY month;


#3. возрастные группы клиентов с шагом 10 лет и отдельно клиентов, у которых нет данной информации, с параметрами сумма и количество
# операций за весь период, и поквартально - средние показатели и %.

SELECT CASE WHEN c.Age IS NULL THEN 'No Age' 
ELSE CONCAT(FLOOR(c.Age/10)*10,'-',FLOOR(c.Age/10)*10+9) END AS age_group,
CONCAT(YEAR(t.date_new), '-', QUARTER(t.date_new)) AS period,
COUNT(DISTINCT t.ID_client) AS clients_count,
COUNT(t.Id_check) AS total_ops,
SUM(t.Sum_payment) AS total_sum,
ROUND(AVG(t.Sum_payment),2) AS avg_sum_per_check,
ROUND(COUNT(t.Id_check)/COUNT(DISTINCT t.ID_client),2) AS avg_ops_per_client
FROM transactions t
LEFT JOIN customer c ON t.ID_client = c.Id_client
GROUP BY period, age_group
ORDER BY period, age_group;





