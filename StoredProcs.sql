CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateFinancialYearData`(
    IN v_GoalId INT,
    IN v_Year INT, 
    IN v_MonthlyInvestment DECIMAL(18,2),
    IN v_Month INT
)
BEGIN
    DECLARE FYear INT;
    DECLARE ExistingEntry INT;
    DECLARE CurrentYear INT;
    DECLARE CurrentMonth INT;

    SET CurrentYear = YEAR(CURRENT_DATE);
    SET CurrentMonth = MONTH(CURRENT_DATE);

    -- financial year calculation
    IF v_Month < 4 THEN
        SET FYear = v_Year - 1;
    ELSE
        SET FYear = v_Year;
    END IF;

	SELECT COUNT(*) INTO ExistingEntry 
    FROM FinancialYearData as fy
    WHERE fy.GoalId = v_GoalId AND fy.Year = v_Year AND fy.`Month` = v_Month;

    IF (v_Year = CurrentYear AND v_Month < CurrentMonth) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cant create an entry for previous month.';
    
    ELSE
        INSERT INTO FinancialYearData (`GoalId`, `Year`, `MonthlyInvestment`, `Month`, `FYear`)
        VALUES (v_GoalId, v_Year, v_MonthlyInvestment, v_Month, FYear);
        
        UPDATE Progress 
        SET TotalContribution = TotalContribution + v_MonthlyInvestment
        WHERE GoalId = v_GoalId;
    END IF;
END


CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateGoal`(
    IN v_ProfileId INT,
    IN CurrentAge INT,
    IN RetirementAge INT,
    IN TargetSavings DECIMAL(18,2),
    IN CurrentSavings DECIMAL(18,2)
)
BEGIN
    DECLARE MonthlyContribution DECIMAL(18,2);
    DECLARE NewGoalId INT;
    DECLARE ExistingGoalId INT;

    -- Check if goal already exists
    SELECT GoalId INTO ExistingGoalId FROM Goals WHERE ProfileId = v_ProfileId LIMIT 1;

    IF ExistingGoalId IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Goal already exists';
    ELSE
        -- Calculate monthly contribution
        SET MonthlyContribution = (TargetSavings - CurrentSavings) / ((RetirementAge - CurrentAge) * 12);

        -- Insert new goal
        INSERT INTO Goals (ProfileId, CurrentAge, RetirementAge, TargetSavings, CurrentSavings, MonthlyContribution)
        VALUES (v_ProfileId, CurrentAge, RetirementAge, TargetSavings, CurrentSavings, MonthlyContribution);
        
        -- Retrieve newly inserted GoalId
        SET NewGoalId = LAST_INSERT_ID();

        -- Insert into Progress table
        INSERT INTO Progress (GoalId, TotalContribution)
        VALUES (NewGoalId, CurrentSavings);

        -- Return the newly created goal
        SELECT * FROM Goals WHERE GoalId = NewGoalId;
    END IF;
END


CREATE DEFINER=`root`@`localhost` PROCEDURE `GetFinancialYearData`(
    IN v_GoalId INT
)
BEGIN
    SELECT Month, Year, MonthlyInvestment,Fyear
    FROM FinancialYearData
    WHERE v_GoalId = GoalId;
END


CREATE DEFINER=`root`@`localhost` PROCEDURE `GetGoal`(
    IN v_ProfileId INT
)
BEGIN
    SELECT * FROM Goals
    WHERE ProfileId = v_ProfileId;
END


CREATE DEFINER=`root`@`localhost` PROCEDURE `GetProgressByGoalId`(
    IN GoalId INT
)
BEGIN
    SELECT 
        p.GoalId, 
        g.TargetSavings, 
        p.TotalContribution,
        (p.TotalContribution / g.TargetSavings) * 100 AS ProgressPercentage
    FROM Progress p
    INNER JOIN Goals g ON p.GoalId = g.GoalId
    WHERE p.GoalId = GoalId;
END


CREATE DEFINER=`root`@`localhost` PROCEDURE `ValidateLogin`(
    IN v_UserName VARCHAR(255),
    IN v_Password VARCHAR(255)
)
BEGIN
    SELECT ProfileId, FirstName, LastName, Age, Gender, UserName
    FROM Profiles
    WHERE CAST(v_UserName AS BINARY) = CAST(UserName AS BINARY)
          AND CAST(v_Password AS BINARY) = CAST(Password AS BINARY);
END