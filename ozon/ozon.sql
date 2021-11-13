-- 1. Посчитать % изменение количества клиентов, совершивших покупку, месяц-к-месяцу.

WITH orders_by_month AS(
            SELECT COUNT(DISTINCT client_id) AS qty,
                   strftime('%m', order_date) AS Month,
                   LAG(COUNT(DISTINCT client_id), 1, 0) OVER(ORDER BY 2) AS prev_qty
              FROM Orders
             GROUP BY 2
                        )

SELECT Month,
       ((qty - prev_qty) * 100 / 
                        prev_qty) || "%" AS diff_pct
  FROM orders_by_month;
  
-- 2. Вывести сумму GMV (Gross Merchandise Value) с нарастающим итогом по дням.

SELECT fact_date,
       SUM(gmv) OVER(ORDER BY fact_date) AS run_total
  FROM Gross
 ORDER BY 1;
 
-- 3. Получить время отклика на каждое письмо (письмо идентифицируется по полю mail_id), отправленное пользователем mr_employee@ozon.ru.

WITH prev_mail AS (
                SELECT mail_id,
                       LAG(timestamp, 1, 0) OVER(PARTITION BY mail_subject
                                ORDER BY timestamp) AS prev_timestamp
                  FROM mails
                  )

SELECT m.mail_id,
       CAST((JULIANDAY(m.timestamp) - JULIANDAY(pm.prev_timestamp)) * 24 * 60
                   AS INTEGER) AS respond_minutes
  FROM mails AS m
       JOIN prev_mail AS pm
       ON pm.mail_id = m.mail_id
 WHERE prev_timestamp != 0
   AND m.mail_to = 'mr_employee@ozon.ru';

-- 4. Вывести id сотрудников с разницей в заработной плате в пределах 5000 рублей.

SELECT DISTINCT s1.employee_id
  FROM salaries AS s1, salaries AS s2
 WHERE s2.salary_rub BETWEEN (s1.salary_rub - 5000)
                         AND (s1.salary_rub + 5000)
   AND s1.employee_id != s2.employee_id;   