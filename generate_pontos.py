import datetime
import random

# Employee ID
id_funcionario = 1

# Location (Franca-SP)
latitude = -20.5144095
longitude = -47.4004061

# Month and year
year = 2025
month = 10

# Get the number of days in the month
num_days = (datetime.date(year, month + 1, 1) - datetime.date(year, month, 1)).days if month < 12 else 31

sql_statements = []

for day in range(1, num_days + 1):
    try:
        date = datetime.date(year, month, day)
    except ValueError:
        continue
        
    if date.weekday() < 5:  # Monday to Friday
        # Clock in (08:00 to 08:05)
        clock_in_minute = random.randint(0, 5)
        clock_in = datetime.datetime(year, month, day, 8, clock_in_minute)
        sql_statements.append(f"INSERT INTO Pontos (id_funcionario, latitude, longitude, criado_em) VALUES ({id_funcionario}, {latitude}, {longitude}, '{clock_in.isoformat()}');")

        # Lunch start (12:00 - 12:05)
        lunch_start_minute = random.randint(0, 5)
        lunch_start = datetime.datetime(year, month, day, 12, lunch_start_minute)
        sql_statements.append(f"INSERT INTO Pontos (id_funcionario, latitude, longitude, criado_em) VALUES ({id_funcionario}, {latitude}, {longitude}, '{lunch_start.isoformat()}');")

        # Lunch end (13:00 - 13:05)
        lunch_end_minute = random.randint(0, 5)
        lunch_end = datetime.datetime(year, month, day, 13, lunch_end_minute)
        sql_statements.append(f"INSERT INTO Pontos (id_funcionario, latitude, longitude, criado_em) VALUES ({id_funcionario}, {latitude}, {longitude}, '{lunch_end.isoformat()}');")

        # Clock out (17:00 - 17:05)
        clock_out_minute = random.randint(0, 5)
        clock_out = datetime.datetime(year, month, day, 17, clock_out_minute)
        sql_statements.append(f"INSERT INTO Pontos (id_funcionario, latitude, longitude, criado_em) VALUES ({id_funcionario}, {latitude}, {longitude}, '{clock_out.isoformat()}');")

with open('insert_pontos.sql', 'w') as f:
    for statement in sql_statements:
        f.write(statement + '\n')

print(f"{len(sql_statements)} INSERT statements generated in insert_pontos.sql")
