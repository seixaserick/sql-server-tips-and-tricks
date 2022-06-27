 
/*
A CPF number is the Brazilian Tax ID. Today, as a person, you need CPF for almost everything in Brazil. 

The CPF has 11 digits (9 digits + 2 checking digits). Example: "12345678901" or formatted as "123.456.789-01" where the last 2 digits "01" are the digest value (validator).

In this example I created a SQL scalar-valued function to generate random fake CPF numbers with valid digest digits (last 2 digits).

We use this function to populate test data without LGPD regulation problems.  

LGPD is the Brazilian federal law for Customer Data Protection and regulation (like GDPR, CCPA, POPI - Privacy Regulations)

From the first 9 numbers, the two checking digits are generated.


Checking digits calculation:

First digit (J):

    Multiply each digit of the first 9 by a constant (from 10 to 2):

    sumJ = @n9 * 2 + @n8 * 3 + @n7 * 4 + @n6 * 5 + @n5 * 6 + @n4 * 7 + @n3 * 8 + @n2 * 9 + @n1 * 10
    J = sumJ % 11
    Divide this sum by 11 and if the remainder is 0 or 1, J will be 0. If the remainder is >=2, J will be 11 - remainder.

Second digit (K): (Same calculation but including digit J)

    Multiply each digit of the first 10 by a constant:
    11A + 10B + 9C + 8D + 7E + 6F + 5G + 4H + 3I + 2J

    Divide this sum by 11 and if the remainder is 0 or 1, K will be 0. If the remainder is >=2, K will be 11 - remainder.

*/

--CREATE OR ALTER statement only works in SQL 2016 version or greater. Use DROP + CREATE in previous SQL versions.
CREATE OR ALTER FUNCTION dbo.GenerateFakeCpf()
RETURNS  VARCHAR(11)
AS
BEGIN
   /* This function returns a varchar(11) with a fake, but valid, CPF number to be used as testing data according to data protection regulations  */
   DECLARE
        @n1 INT,
        @n2 INT,
        @n3 INT,
        @n4 INT,
        @n5 INT,
        @n6 INT,
        @n7 INT,
        @n8 INT,
        @n9 INT,
        @n10 INT,
        @n11 INT,
        @n12 INT,
        @d1 INT,
        @d2 INT,
	  @rndString VARCHAR(9)

        --creating the CPF prefix => random 9 chars ("123456789") using CHECKSUM( PWDENCRYPT(N'')) because rand() produces an error in SQL scalar-valued functions
	  SET @rndString = RIGHT(  CAST( ABS( CHECKSUM( PWDENCRYPT(N''))) AS VARCHAR) + CAST( ABS( CHECKSUM( PWDENCRYPT(N''))) AS VARCHAR), 9)
        
        SET @n1 = CAST( SUBSTRING(@rndString,1,1) AS INT)
        SET @n2 = CAST( SUBSTRING(@rndString,2,1) AS INT)
        SET @n3 = CAST( SUBSTRING(@rndString,3,1) AS INT)
        SET @n4 = CAST( SUBSTRING(@rndString,4,1) AS INT)
        SET @n5 = CAST( SUBSTRING(@rndString,5,1) AS INT)
        SET @n6 = CAST( SUBSTRING(@rndString,6,1) AS INT)
        SET @n7 = CAST( SUBSTRING(@rndString,7,1) AS INT)
        SET @n8 = CAST( SUBSTRING(@rndString,8,1) AS INT)
        SET @n9 = CAST( SUBSTRING(@rndString,9,1) AS INT)
        SET @d1 = @n9 * 2 + @n8 * 3 + @n7 * 4 + @n6 * 5 + @n5 * 6 + @n4 * 7 + @n3 * 8 + @n2 * 9 + @n1 * 10
        SET @d1 = 11 - ( @d1 % 11 )
 
        IF ( @d1 >= 10 )
            SET @d1 = 0
 
        SET @d2 = @d1 * 2 + @n9 * 3 + @n8 * 4 + @n7 * 5 + @n6 * 6 + @n5 * 7 + @n4 * 8 + @n3 * 9 + @n2 * 10 + @n1 * 11
        SET @d2 = 11 - ( @d2 % 11 )
 
        IF ( @d2 >= 10 )
            SET @d2 = 0
    
     RETURN CAST(@n1 AS VARCHAR) + CAST(@n2 AS VARCHAR) + CAST(@n3 AS VARCHAR) +   CAST(@n4 AS VARCHAR) + CAST(@n5 AS VARCHAR) + CAST(@n6 AS VARCHAR) + CAST(@n7 AS VARCHAR) + CAST(@n8 AS VARCHAR) + CAST(@n9 AS VARCHAR) + CAST(@d1 AS VARCHAR) + CAST(@d2 AS VARCHAR);
 
END
GO
 