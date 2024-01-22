SELECT
    o.order_no,
    o.total_amt,
    COUNT(i.item) AS item_quantity,
    COALESCE(i.item_type, 'GiftCard') AS modified_item_type,
    COALESCE(i.item, 'GiftCard') AS modified_item,
    i.order_start,
    TIMEDIFF(i.order_end, i.order_start) AS prep_length,
    o.zip,
    d.markup,
    CASE WHEN ROW_NUMBER() OVER (PARTITION BY o.order_no ORDER BY o.order_no) = 1
         THEN o.total_amt
         ELSE NULL
    END AS distinct_order_total_amt
FROM
    orders o
LEFT JOIN item i ON o.order_no = i.order_no
LEFT JOIN delivery d ON o.order_no = d.order_no
GROUP BY
    o.order_no,
    o.total_amt,
    modified_item_type,
    modified_item,
    i.order_start,
    prep_length,
    o.zip,
    d.markup;
