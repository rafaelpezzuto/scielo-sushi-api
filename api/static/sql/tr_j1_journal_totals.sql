DELIMITER $$
CREATE PROCEDURE TR_J1_JOURNAL_TOTALS(IN beginDate date, IN endDate date, IN issn varchar(9))
BEGIN
    SELECT journal_id,
           min(year_month_day) AS beginDate,
           max(year_month_day) AS endDate,
           cj.online_issn AS onlineISSN,
           cj.print_issn AS printISSN,
           cjc.title,
           cjc.publisher_name AS publisherName,
           cjc.uri,
           sum(total_item_requests) AS totalItemRequests,
           sum(unique_item_requests) AS uniqueItemRequests
    FROM counter_article_metric
             JOIN counter_article ca ON counter_article_metric.fk_article_id = ca.article_id
             JOIN counter_journal cj ON cj.journal_id = ca.fk_art_journal_id
             JOIN counter_journal_collection cjc ON cj.journal_id = cjc.fk_col_journal_id
    WHERE (print_issn = issn OR online_issn = issn OR pid_issn = issn) AND (year_month_day >= beginDate AND year_month_day <= endDate AND cjc.name = 'scl')
    GROUP BY journal_id;
END $$
DELIMITER ;