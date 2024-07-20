CREATE
    FUNCTION nilsimsa_hash(data BLOB) RETURNS VARCHAR(64) 
    DETERMINISTIC NO SQL
BEGIN
    DECLARE count INT DEFAULT 0;
    DECLARE acc VARBINARY(256) DEFAULT REPEAT(CHAR(0x00), 256);
    DECLARE lastch0 INT DEFAULT -1;
    DECLARE lastch1 INT DEFAULT -1;
    DECLARE lastch2 INT DEFAULT -1;
    DECLARE lastch3 INT DEFAULT -1;
    DECLARE i INT DEFAULT 1;
    DECLARE ch TINYINT;
    DECLARE total INT DEFAULT 0;
    DECLARE threshold DOUBLE;
    DECLARE offset INT;
    DECLARE current INT;
    DECLARE code VARBINARY(32) DEFAULT REPEAT(CHAR(0x00), 32);

    IF data IS NULL OR data = '' THEN RETURN NULL; END IF;

    -- Update logic
    WHILE i <= LENGTH(data) DO
        SET ch = ORD(SUBSTRING(data, i, 1));
        SET count = count + 1;

        IF lastch1 > -1 THEN
            SET acc = INSERT(acc, tran3(ch, lastch0, lastch1, 0) + 1, 1, CHAR(ORD(SUBSTRING(acc, tran3(ch, lastch0, lastch1, 0) + 1, 1)) + 1));
        END IF;

        IF lastch2 > -1 THEN
            SET acc = INSERT(acc, tran3(ch, lastch0, lastch2, 1) + 1, 1, CHAR(ORD(SUBSTRING(acc, tran3(ch, lastch0, lastch2, 1) + 1, 1)) + 1));
            SET acc = INSERT(acc, tran3(ch, lastch1, lastch2, 2) + 1, 1, CHAR(ORD(SUBSTRING(acc, tran3(ch, lastch1, lastch2, 2) + 1, 1)) + 1));
        END IF;

        IF lastch3 > -1 THEN
            SET acc = INSERT(acc, tran3(ch, lastch0, lastch3, 3) + 1, 1, CHAR(ORD(SUBSTRING(acc, tran3(ch, lastch0, lastch3, 3) + 1, 1)) + 1));
            SET acc = INSERT(acc, tran3(ch, lastch1, lastch3, 4) + 1, 1, CHAR(ORD(SUBSTRING(acc, tran3(ch, lastch1, lastch3, 4) + 1, 1)) + 1));
            SET acc = INSERT(acc, tran3(ch, lastch2, lastch3, 5) + 1, 1, CHAR(ORD(SUBSTRING(acc, tran3(ch, lastch2, lastch3, 5) + 1, 1)) + 1));
            SET acc = INSERT(acc, tran3(lastch3, lastch0, ch, 6) + 1, 1, CHAR(ORD(SUBSTRING(acc, tran3(lastch3, lastch0, ch, 6) + 1, 1)) + 1));
            SET acc = INSERT(acc, tran3(lastch3, lastch2, ch, 7) + 1, 1, CHAR(ORD(SUBSTRING(acc, tran3(lastch3, lastch2, ch, 7) + 1, 1)) + 1));
        END IF;

        SET lastch3 = lastch2;
        SET lastch2 = lastch1;
        SET lastch1 = lastch0;
        SET lastch0 = ch;
        SET i = i + 1;
    END WHILE;

    -- Digest logic
    CASE
        WHEN count = 0 OR count = 1 OR count = 2 THEN
            SET total = 0;
        WHEN count = 3 THEN
            SET total = 1;
        WHEN count = 4 THEN
            SET total = 4;
        ELSE
            SET total = (8 * count) - 28;
    END CASE;

    SET threshold = total / 256;

    SET i = 0;
    WHILE i <= 255 DO
        SET offset = i >> 3;
        SET current = ORD(SUBSTRING(code, offset + 1, 1));
        SET code = INSERT(code, offset + 1, 1, CHAR(current + (IF(ORD(SUBSTRING(acc, i + 1, 1)) > threshold, 1, 0) << (i & 7))));
        SET i = i + 1;
    END WHILE;
    RETURN LOWER(HEX(reverse(code)));
END;
