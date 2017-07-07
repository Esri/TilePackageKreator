import QtQuick 2.7

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Sql 1.0

import "singletons" as Singletons

Item {
    id: appDb

    //--------------------------------------------------------------------------

    SqlDatabase {
        id: db
        databaseName: dataFolder.filePath(Singletons.Constants.kDatabaseName)

        onErrorChanged: {
            if (error) {
                console.log("error:", error.toString());
            }
        }
    }

    //--------------------------------------------------------------------------

    function exists() {
        if (dataFolder.fileExists(Singletons.Constants.kDatabaseName)){
            return true;
        }
        else {
            return false;
        }
    }

    //--------------------------------------------------------------------------

    function write(sql){

        db.open();
        var query;

        try {
            query = db.query(sql);
            if (query.error) {
                console.log("Command error:", query.error.toString());
            }
        }
        catch(e) {
            console.log(e)
        }
        finally {
            db.close();
        }

        console.log(query);

        return query;
    }

    //--------------------------------------------------------------------------

    function read(sql){

        db.open();
        var query;

        try {
            query = db.queryModel(sql);
            if (query.error) {
                console.log("Command error:", query.error.toString());
            }
        }
        catch(e) {
            console.log(e)
        }
        finally {
            db.close();
        }

        return query;
    }

    //--------------------------------------------------------------------------

    function truncate(tableName) {
        db.open();
        var truncateSql = "DELETE FROM '%1'".arg(tableName)

        try {
            db.query(truncateSql);
            db.query("VACUUM");
        }
        catch(e) {
            console.log(e)
        }
        finally {
            db.close();
        }
    }

    //--------------------------------------------------------------------------

    function readSql(sqlFile) {

        var text = folder.readTextFile(sqlFile);

        var sqlCommands =  text.split(";");

        return sqlCommands;
    }

    //--------------------------------------------------------------------------

    function createDatabase(){

        if (dataFolder.makeFolder()) {
            var sqlFile = "tilepackagekreator.sql";

            if (!db.open()) {
                console.error("Error opening database:", filePath);
            }

            var sqlCommands = readSql(sqlFile);

            try {
                sqlCommands.forEach(function (sql) {
                    sql = sql.trim();
                    if (!sql.length) {
                        return;
                    }
                    var query = db.query(sql);

                    if (query.error) {
                        // throw error
                    }
                });
            }
            catch(e) {
            }
            finally {
                db.close();
            }
        }
        else {
            console.log("---------------didn't make folder")
        }
    }

    //--------------------------------------------------------------------------

    FileFolder {
        id: folder

        url: "sql"
    }

    //--------------------------------------------------------------------------

    FileFolder {
        id: dataFolder
        path: Singletons.Constants.kDatabasePath
    }

    // END /////////////////////////////////////////////////////////////////////
}
