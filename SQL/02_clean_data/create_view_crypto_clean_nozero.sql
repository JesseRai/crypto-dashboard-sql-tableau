-- Create a view to filter out zero values from crypto_clean
CREATE VIEW crypto_clean_nozero AS
SELECT *
FROM crypto_clean
WHERE Close > 0
  AND Open > 0
  AND High > 0
  AND Low > 0;
