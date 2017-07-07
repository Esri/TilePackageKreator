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

    function transact(sql){

        db.open();

        try {
            var query = db.query(sql);
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
