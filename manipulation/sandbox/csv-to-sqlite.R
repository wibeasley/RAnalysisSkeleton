# library(sqldf)
requireNamespace("RSQLite")
requireNamespace("fs")

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
# sql <-
#   sprintf(
#     "
#       CREATE VIRTUAL TABLE iris
#       USING csv(
#         schema   = %s,
#         filename = 'iris.csv',
#         header   = TRUE
#       );
#     ",
#     sql_create
#   )

path_csv  <- "data-unshared/derived/iris.csv"
path_db  <- "data-unshared/derived/iris.sqlite3"
cat(file = path_db)


# create a test file
write.table(iris, path_csv, sep = ",", quote = FALSE, row.names = FALSE)


cnn <- DBI::dbConnect(RSQLite::SQLite(), path_db)
RSQLite::initExtension(cnn, "csv")

DBI::dbExecute(cnn, sql_create)
DBI::dbWriteTable(cnn, "iris", path_csv, append = TRUE)

fs::file_delete(path_csv)

# DBI::dbExecute(cnn, "CREATE VIRTUAL TABLE iris2 USING csv(filename='iris.csv', header = TRUE);")
# DBI::dbExecute(cnn, sql)
DBI::dbExecute(cnn, "VACUUM;")
# read.csv.sql("iris.csv", sql = "INSERT INTO main.iris select * from file", dbname = path_db)
# read.csv.sql("iris.csv", sql = "INSERT INTO main.iris select * from file", dbname = path_db)
#
# # look at first three lines
# sqldf("select * from iris limit 3") |>
#   str()
# # sqldf()
# DBI::dbColumnInfo(cnn)
ds <- DBI::dbGetQuery(cnn, "select * from iris limit 3")
str(ds)
ds

# rs <- dbSendQuery(cnn, "select * from iris limit 3")
# dbColumnInfo(rs)
# dbFetch(rs)


DBI::dbDisconnect(cnn)
# fs::file_delete(path_db)


# https://stackoverflow.com/questions/67152636/sql-statements-must-be-issued-with-dbexecute-or-dbsendstatement-instead-of-d
