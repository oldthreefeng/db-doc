package main

import (
	"db-doc/database"
	"db-doc/model"
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
)

var (
	h bool
	Buildstamp = ""
	Githash    = ""
	Goversion  = ""
	dbConfig *model.DbConfig
)

func main() {
	flag.Parse()
	if h {
		flag.Usage()
		return
	}
	Setup()
	// generate
	database.Generate(dbConfig)
}

// GetDefaultConfig get default config
func Setup() {
	GetConfig()
}

func init() {
	flag.BoolVar(&h, "h", false, "this help")
	flag.Usage = usage
}

func usage() {
	fmt.Fprintf(os.Stderr, `db-doc 是一款生成在线数据库文档的小工具, 
run "db-doc -h" get more help, more see https://github.com/viodo/db-doc
`)
	fmt.Printf("\ndb-doc version :       %s\n", "v1.0.0")
	fmt.Printf("Git Commit Hash:     %s\n", Githash)
	fmt.Printf("UTC Build Time :     %s\n", Buildstamp)
	fmt.Printf("Go Version:          %s\n", Goversion)
}

func GetConfig() *model.DbConfig {
	if dbConfig == nil {
		cfg, err := loadConfig()
		if err != nil {
			log.Fatal(err)
			return nil
		}
		dbConfig = &cfg
	}
	return dbConfig
}

func loadConfig() (config model.DbConfig, err error) {
	data, err := loadFile("./conf.json")
	if err != nil {
		return
	}
	err = json.Unmarshal(data, &config)
	if err != nil {
		return
	}

	return
}

func loadFile(fileName string) ([]byte, error) {
	file, err := os.Open(fileName)
	if err != nil {
		return nil, err
	}
	return ioutil.ReadAll(file)
}