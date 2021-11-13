-- Есть две таблицы Table1, Table2 со списком id. Найдите все id из Table1, кроме тех, которые есть в Table2.
SELECT t1.id
  FROM Table1 AS t1
       LEFT JOIN Table2 AS t2
       ON t1.id = t2.id
       WHERE t2.id IS NULL;
       
SELECT t1.id
  FROM Table1 AS t1
 WHERE t1.id NOT IN (
                    SELECT t2.id
                      FROM Table2 AS t2
                      );
                      
            
                      
                      
/*
Имеются две таблицы:
Таблица users : user_id , login , hash_password
Таблица cards : card_id , user_id , name , surname
Напишите SQL запрос, выбирающий пользователей (user_id и login), у которых заведено более одной карточки.
*/
WITH cards_qty AS (
                SELECT COUNT(card_id) AS qty,
                        user_id
                  FROM cards
                 GROUP BY user_id
                 )
                 
SELECT u.user_id, u.login
  FROM users AS u
       LEFT JOIN cards_qty AS cq
       ON u.user_id = cq.user_id
 WHERE cq.qty > 1;
 
 
 /*
 У вас есть таблица quality_score с результатами внутренней проверки качества звонков операторов.
В случае несогласия с оценкой, оператор может обжаловать её, тогда новая оценка по звонку запишется в эту же таблицу новой строкой.
Таким образом, по одному звонку может быть сохранено несколько записей об оценке.
Поля таблицы:
• CALL_ID – id звонка
• CALL_DT - дата совершения звонка
• OPERATOR – имя оператора
• SCORE_DT - дата оценки
• SCORE - оценка
Рассчитайте итоговую среднюю оценку по всем звонкам, которые были совершены в августе 2021.
Если записей с оценками по звонку несколько, то берем самую свежую оценку.
*/
WITH max_date AS(
                    SELECT MAX(qs2.SCORE_DT) AS max_d,
                           CALL_ID
                      FROM quality_score AS qs2
                     GROUP BY qs2.CALL_ID
                     )
                     
SELECT AVG(qs1.SCORE) AS avg_score
  FROM quality_score AS qs1
       LEFT JOIN max_date AS md
       ON md.CALL_ID = qs1.CALL_ID
 WHERE strto_date(qs1.CALL_DT, '%Y/%m') = '2021/08'
   AND qs1.SCORE_DT = md.max_d;