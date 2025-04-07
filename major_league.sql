CREATE DATABASE IF NOT EXISTS major_leagues;

USE major_leagues;

# CREATING TABLES #

CREATE TABLE IF NOT EXISTS teams (
	Team_Id int not null auto_increment,
    Team_Name varchar(25) not null,
    League enum ("American", "National") not null,
    Division enum ("Central", "East", "West") not null,
		PRIMARY KEY (Team_Id)
);

CREATE TABLE IF NOT EXISTS managers (
	Manager_Id int not null auto_increment,
    Mgr_FirstN varchar (15) not null,
    Mgr_LastN varchar (15) not null,
		PRIMARY KEY (Manager_Id)
);

CREATE TABLE IF NOT EXISTS players  (
	Player_Id int not null auto_increment,
    Player_FirstN varchar (15) not null,
    Player_LastN varchar (15) not null,
    DOB date not null,
    Phone varchar(15) not null,
    Country varchar (15) not null,
    Email varchar (50) not null,
    Height_cm double (3,2) not null,
		PRIMARY KEY (Player_Id)
);

CREATE TABLE IF NOT EXISTS team_members (
	Player_Id int not null,
    Team_Id int not null,
    Manager_Id int not null,
		PRIMARY KEY (Player_Id),
        FOREIGN KEY (Player_Id) REFERENCES players (Player_Id),
        FOREIGN KEY (Team_Id) REFERENCES teams (Team_Id),
        FOREIGN KEY (Manager_Id) REFERENCES managers (Manager_Id)
);

CREATE TABLE IF NOT EXISTS player_position (
	Player_Id int not null,
    Position_Year year not null,
    Position enum ("Catcher", "Designated Hitter", "First Baseman", "Outfielder", "Pitcher", "Second Baseman", "Shortstop", "Third Baseman"),
		PRIMARY KEY (Player_Id, Position_Year),
        FOREIGN KEY (Player_Id) REFERENCES players (Player_Id)
);

CREATE TABLE IF NOT EXISTS player_salary (
	Player_Id int not null,
    Salary_Year year not null,
    Salary_Category enum("A", "B", "C"),
    Salary_Amount bigint,
		PRIMARY KEY (Player_Id, Salary_Year),
        FOREIGN KEY (Player_Id) REFERENCES players (Player_Id)
);

CREATE TABLE IF NOT EXISTS player_extra_income (
	Extra_Income_Id int not null auto_increment,
	Player_Id int not null,
    Year year not null,
    Extra_Income_Type enum ("Win Bonus", "Marketing", "Endorsements", "Special Events", "Community Engagement", "All-Star Game Participation") not null,
    Extra_Income_Amount double (30,2) not null,
		PRIMARY KEY (Extra_Income_Id),
        FOREIGN KEY (Player_Id) REFERENCES player_salary (Player_Id)
);


CREATE TABLE IF NOT EXISTS player_taxes (
	Player_Id int not null,
    Tax_Year year not null,
    Tax_Amount double (15,2),
		PRIMARY KEY (Player_Id),
        FOREIGN KEY (Player_Id) REFERENCES players (Player_Id)
);

CREATE TABLE IF NOT EXISTS player_checkup (
		Player_Id int not null,
        CheckUp_Date date not null,
        Weight_kg decimal (5,2) not null,
        Blood_Pressure varchar (10) not null,
        Drug_Test enum ("Positive", "Negative") not null,
        Comments text, 
			PRIMARY KEY (Player_Id, CheckUp_Date),
			FOREIGN KEY (Player_Id) REFERENCES players (Player_Id)
);

CREATE TABLE IF NOT EXISTS manager_payment (
	Manager_Id int not null,
    Player_Id int not null,
    MgrP_Year year not null,
    Mgr_Percentage decimal(3,2),
		PRIMARY KEY (Manager_Id, Player_id, MgrP_Year),
        FOREIGN KEY (Manager_Id) REFERENCES managers (Manager_Id),
        FOREIGN KEY (Player_Id) REFERENCES players (Player_Id)
);



/* ALTER TABLES */
# alter table mlb_original_data rename column ï»¿Player_FirstN to Player_FirstN;


/*INSERTING DATA*/

# Teams #
INSERT INTO teams(Team_Name, League, Division)
	SELECT DISTINCT Team, League, Division 
	FROM mlb_original_data;

# Managers #
INSERT INTO managers(Mgr_FirstN, Mgr_LastN)
	SELECT DISTINCT Mgr_FirstN, Mgr_LastN
	FROM mlb_original_data;

# Players #
INSERT INTO players (Player_FirstN, Player_LastN, DOB, Phone, Country, Email, Height_cm)
	SELECT Player_FirstN, Player_LastN, Date_of_Birth, Phone_Number, Country, Email, Height_cm
	FROM mlb_original_data;

# Team Members #
INSERT INTO team_members (Player_Id, Team_Id, Manager_Id)
	SELECT p.Player_Id, t.Team_Id, m.Manager_Id
	FROM mlb_original_data o
	JOIN players p ON o.Phone_Number = p.Phone
	JOIN teams t ON o.Team = t.Team_Name
	JOIN managers m ON CONCAT(o.Mgr_FirstN, ' ', o.Mgr_LastN) = CONCAT(m.Mgr_FirstN, ' ', m.Mgr_LastN);

# Player Position #
select * from player_position; 
INSERT INTO player_position (Player_Id, Position_Year, Position)
	SELECT p.Player_Id, 2012, o.Position_2012
	FROM players p JOIN mlb_original_data o ON o.Phone_Number = p.Phone
		WHERE o.Position_2012 IS NOT NULL;

INSERT INTO player_position (Player_Id, Position_Year, Position)
	SELECT p.Player_Id, 2013, o.Position_2013
	FROM players p JOIN mlb_original_data o ON o.Phone_Number = p.Phone
		WHERE o.Position_2013 IS NOT NULL;

INSERT INTO player_position (Player_Id, Position_Year, Position)
	SELECT p.Player_Id, 2014, o.Position_2014
	FROM players p JOIN mlb_original_data o ON o.Phone_Number = p.Phone
		WHERE o.Position_2014 IS NOT NULL;

# Player Salary #
INSERT INTO player_salary 
	SELECT p.Player_Id, 2012, o.Salary_Category_2012, o.salary_2012
	FROM players p JOIN mlb_original_data o on o.Phone_Number = p.Phone
		WHERE o.Salary_Category_2012 IS NOT NULL;

INSERT INTO player_salary 
	SELECT p.Player_Id, 2013, o.Salary_Category_2013, o.salary_2013
	FROM players p JOIN mlb_original_data o on o.Phone_Number = p.Phone
		WHERE o.Salary_Category_2013 IS NOT NULL;

INSERT INTO player_salary /*Skip null years*/
	SELECT p.Player_Id, 2014, o.Salary_Category_2014, o.salary_2014
	FROM players p JOIN mlb_original_data o on o.Phone_Number = p.Phone
		WHERE o.Salary_Category_2014 IS NOT NULL;

# Player Extra Income # 
INSERT INTO player_extra_income (Player_Id, Year, Extra_Income_Type, Extra_Income_Amount)
	SELECT p.Player_Id, 2012, "Win Bonus", o.Bonus_per_win
	FROM players p JOIN mlb_original_data o on o.Phone_Number = p.Phone;
	SELECT * from player_salary;

# Player Taxes #
INSERT INTO player_taxes (Player_Id, Tax_Year, Tax_Amount)
	SELECT p.Player_Id, 2012, o.Taxes_2012
	FROM players p JOIN mlb_original_data o on o.Phone_Number = p.Phone;

# Player Check Up #
INSERT INTO player_checkup (Player_Id, CheckUp_Date, Weight_Kg, Blood_Pressure, Drug_Test, Comments)
	SELECT p.Player_Id, o.Weight_Date, o.Weight_Kg, "120/80", "Negative", NULL
	FROM players p JOIN mlb_original_data o on o.Phone_Number = p.Phone;

/* In this case, to populate this table, the columns "Blood_Pressure", "Drug_Test" and 
"Comments" will have a default value. */


##### QUERIES #####

SELECT p.Country, count(distinct concat(p.Player_FirstN," ",p.Player_LastN)) as DistinctPlayerName, 
round(avg(timestampdiff(YEAR, P.DOB, CURDATE()))) AS PlayerAgeAvg, round(avg(p.Height_cm)) as HeightAverage, 
round(avg(cu.Weight_kg)) as WeightAverage
	FROM players p JOIN player_checkup cu on p.Player_Id = cu.Player_Id 
	GROUP BY p.country;

SELECT t.League, count(distinct t.Team_Name) as NumberOfTeams, count(distinct concat(m.Mgr_FirstN," ",m.Mgr_LastN)) as NumberOfManagers, 
count(distinct s.Salary_Category) as NumberOfCategories, 
concat("$ ", format(sum(s.Salary_Amount),0)) TotalSalary2013
	FROM teams t JOIN team_members tm ON t.Team_Id = tm.Team_Id 
	JOIN managers m ON tm.Manager_Id = m.Manager_Id
	JOIN players p ON tm.Player_Id = p.Player_Id
	JOIN player_salary s ON s.Player_Id = p.Player_Id
	WHERE s.Salary_Year = 2013
	GROUP BY t.League; 
        
SELECT p.Player_ID, CONCAT(p.Player_FirstN, " ", p.Player_LastN) AS Player_Name, t.Division, t.League, t.Team_Name, 
	CONCAT("$ ", FORMAT(SUM(ex.Extra_Income_Amount), 0)) AS TotalBonusPerWin
	FROM teams t 
	JOIN team_members tm ON t.Team_Id = tm.Team_Id
	JOIN players p ON tm.Player_Id = p.Player_Id
	JOIN player_extra_income ex ON ex.Player_Id = p.Player_Id
	WHERE ex.Player_ID = 25
	GROUP BY p.Player_Id, t.Division, t.League, t.Team_Name;


