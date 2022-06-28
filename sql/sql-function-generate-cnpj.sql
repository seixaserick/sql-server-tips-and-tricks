 
/*

SQL scalar-valued function to generate random fake CNPJ numbers (HQ or branch) with valid checking digits (last 2 digits).

A CNPJ number is the Brazilian Tax ID for companies. Today, any company must have a CNPJ number in Brazil.

The CNPJ has 14 digits (8 digits for root company number + 4 digits for branch identification + 2 checking digits). Example: "12345678000123" or formatted as "12.345.678/0001-23" where the last 2 digits "01" are the digest value (validator).

We use this function to populate test data without LGPD privacy regulation problems.  

LGPD is the Brazilian federal law for Data Protection and regulation (like GDPR, CCPA, POPI - Privacy Regulations)

Checking digits calculation:


First digit (d1):

    Multiply each digit of the first 12 by a constant as following:
    @d1 = @n12 * 2 + @n11 * 3 + @n10 * 4 + @n9 * 5 + @n8 * 6 + @n7 * 7 + @n6 * 8 + @n5 * 9 + @n4 * 2 + @n3 * 3 + @n2 * 4 + @n1 * 5

    Divide this sum by 11 and if the remainder is 0 or 1, d1 will be 0. If the remainder is >=2, d1 will be (11 - remainder).
    @d1 = 11 - ( @d1 % 11 )
    IF (@d1 >= 10) 
        SET @d1 = 0

Second digit (d2): (Same calculation but including digit d1)

    Multiply each digit of the first 13 by a constant as following:
    @d2 = @d1 * 2 + @n12 * 3 + @n11 * 4 + @n10 * 5 + @n9 * 6 + @n8 * 7 + @n7 * 8 + @n6 * 9 + @n5 * 2 + @n4 * 3 + @n3 * 4 + @n2 * 5 + @n1 * 6
    SET @d2 = 11 - ( @d2 % 11 )
    IF (@d2 >= 10) 
        SET @d2 = 0


*/

--CREATE OR ALTER statement only works in SQL 2016 version or greater. Use DROP + CREATE in previous SQL versions.
CREATE OR ALTER FUNCTION dbo.GenerateFakeCnpj()
RETURNS  VARCHAR(14)
AS
BEGIN
   
   /* 
   This function returns a varchar(14) with a fake, but valid, CNPJ number to be used as testing data according to data protection regulations 
   CNPJ format:  12345678/0001-99  =>  "12345678" is the root company number;  "0001" is the branch identification number where 0001 is the HQ;  "99" checking digits 
   This function generates ~ 80% of times a valid CNPJ number for HeadQuarters ("12345678000199") and ~20% of times a branch number ("93454947000234" or "40816995000340")

   " 1  2  3  4  5  6  7  8 /  0   0   0   1 -  9  9" 
   " 1  2  3  4  5  6  7  8 /  0   0   0   2 -  9  9"
   "n1 n2 n3 n4 n5 n6 n7 n8 / n9 n10 n11 n12 - d1 d2"                              "
   
   */
  DECLARE
        @n1  INT,
        @n2  INT,
        @n3  INT,
        @n4  INT,
        @n5  INT,
        @n6  INT,
        @n7  INT,
        @n8  INT,
        @n9  INT,
        @n10 INT,
        @n11 INT,
        @n12 INT,
        @d1  INT,
        @d2  INT,
        @rndString VARCHAR(8)
 

    --creating the CNPJ prefix => random 8 chars ("12345678") using CHECKSUM( PWDENCRYPT(N'')) because rand() produces an error in SQL scalar-valued functions
    SET @rndString = RIGHT( CAST( ABS( CHECKSUM( PWDENCRYPT(N'') )) AS VARCHAR), 8)

    SET @n1  = CAST( SUBSTRING(@rndString,1,1) AS INT)
    SET @n2  = CAST( SUBSTRING(@rndString,2,1) AS INT)
    SET @n3  = CAST( SUBSTRING(@rndString,3,1) AS INT)
    SET @n4  = CAST( SUBSTRING(@rndString,4,1) AS INT)
    SET @n5  = CAST( SUBSTRING(@rndString,5,1) AS INT)
    SET @n6  = CAST( SUBSTRING(@rndString,6,1) AS INT)
    SET @n7  = CAST( SUBSTRING(@rndString,7,1) AS INT)
    SET @n8  = CAST( SUBSTRING(@rndString,8,1) AS INT)

	--generating branch number ("0001"  for head quarters)
    SET @n9  = 0
    SET @n10 = 0
    SET @n11 = 0
    SET @n12 = 1


	--random n12 20% of times with value "2" or "3" instead "1" (simulating branch "0002" or "0003" instead headquarter "0001"). Example: 50.866.372/0003-35
    IF (@n2 % 9 = 0)
        SET @n12 = CASE WHEN @n8 >=5  THEN 2 ELSE 3 END
        
    
	--calculating d1
	SET @d1 = @n12 * 2 + @n11 * 3 + @n10 * 4 + @n9 * 5 + @n8 * 6 + @n7 * 7 + @n6 * 8 + @n5 * 9 + @n4 * 2 + @n3 * 3 + @n2 * 4 + @n1 * 5
    SET @d1 = 11 - ( @d1 % 11 )
    
    IF (@d1 >= 10) 
        SET @d1 = 0
        
	--calculating d2
    SET @d2 = @d1 * 2 + @n12 * 3 + @n11 * 4 + @n10 * 5 + @n9 * 6 + @n8 * 7 + @n7 * 8 + @n6 * 9 + @n5 * 2 + @n4 * 3 + @n3 * 4 + @n2 * 5 + @n1 * 6
    SET @d2 = 11 - ( @d2 % 11 )
    
    IF (@d2 >= 10) 
        SET @d2 = 0
        
   --returning the generated CNPJ without formatting => 83591637000127 OR 50866372000335
    RETURN CAST (@n1 AS VARCHAR) + CAST (@n2  AS VARCHAR) + CAST (@n3  AS VARCHAR) + CAST (@n4  AS VARCHAR) 
         + CAST (@n5 AS VARCHAR) + CAST (@n6  AS VARCHAR) + CAST (@n7  AS VARCHAR) + CAST (@n8  AS VARCHAR) 
         + CAST (@n9 AS VARCHAR) + CAST (@n10 AS VARCHAR) + CAST (@n11 AS VARCHAR) + CAST (@n12 AS VARCHAR) 
         + CAST (@d1 AS VARCHAR) + CAST (@d2  AS VARCHAR);
END
GO
 