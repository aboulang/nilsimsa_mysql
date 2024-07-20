-- Helper function for the hash function
CREATE
    FUNCTION tran3(a INT, b INT, c INT, n INT) 
    RETURNS INT DETERMINISTIC NO SQL
BEGIN
    DECLARE tran BLOB DEFAULT UNHEX(
            CONCAT('02d69e6ff91d04abd022161fd873a1ac3b7062961e6e8f399d05144aa6beae0ecfb99c9ac76813e12da4eb518d646b502',
                   '3800341ecbb71cc7a867f98f2365eee8ece4fb832b65f59dc1b314c7bf063016cba07e81277493cda46fe2f791c9b30e3',
                   '00067e2e0f383321ada554caa729fc5a47697dc595b5f40b90a3816d255535f575740a26bf195c1ac6ff995d84aa663ea',
                   'f78b32043c1ed24eae63f18f3a04257085360c3c0834082d709bd442a67a893e0c2569fd9dd8515b48a27289276deeff8',
                   'b2b7c93d45944b110d65d5348b910cfa87e97c5bb14de5d4cb10a21789bcdbb0e2978852f748d3612c3a2bd18cfbf1cde',
                   '46ae7a9fdc437c8d2f6df58724e'));
    RETURN ((ORD(SUBSTRING(tran, ((a + n) & 255) + 1, 1))
             ^ (ORD(SUBSTRING(tran, b + 1, 1)) * (n + n + 1)))
             + ORD(SUBSTRING(tran, (c ^ ORD(SUBSTRING(tran, n + 1, 1))) + 1, 1))) & 255;
END;
