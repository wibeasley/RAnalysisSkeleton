library(sqldf)

# create a test file
write.table(iris, "iris.csv", sep = ",", quote = FALSE, row.names = FALSE)

# create an empty database.
# can skip this step if database already exists.
# sqldf("attach testingdb as new")
# or: 

sql_create <-
  "
    CREATE TABLE iris (
      'Sepal.Length'  float       not null,
      'Sepal.Width'   float       not null,
      'Petal.Length'  float       not null,
      'Petal.Width'   float       not null,
      Species       varchar(10) not null
    )
  "

path_db <- "testingdb.sqlite3"
cat(file = path_db)


cnn <- DBI::dbConnect(RSQLite::SQLite(), path_db)
RSQLite::initExtension(cnn, "csv")

# DBI::dbExecute(cnn, sql_create)
DBI::dbExecute(cnn, "CREATE VIRTUAL TABLE main.iris USING csv(filename='testingdb.sqlite3');")
# 
# read.csv.sql("iris.csv", sql = "INSERT INTO main.iris select * from file", dbname = path_db)
# read.csv.sql("iris.csv", sql = "INSERT INTO main.iris select * from file", dbname = path_db)
# 
# # look at first three lines
sqldf("select * from main.iris limit 3")
# # sqldf()

DBI::dbDisconnect(cnn)
fs::file_delete(path_db)


# https://stackoverflow.com/questions/67152636/sql-statements-must-be-issued-with-dbexecute-or-dbsendstatement-instead-of-d
