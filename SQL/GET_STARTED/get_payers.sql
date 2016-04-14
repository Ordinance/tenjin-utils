SELECT DISTINCT advertising_id
FROM raw_events 
WHERE event_type = 'purchase';