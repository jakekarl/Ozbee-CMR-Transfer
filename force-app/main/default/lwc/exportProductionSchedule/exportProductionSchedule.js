import { LightningElement, track, api } from "lwc";
// importing accounts
import getProductionScheduleItems from "@salesforce/apex/ExportProductionScheduleController.getProductionScheduleItems";
import getExportScheduleItemsFieldSet from "@salesforce/apex/ExportProductionScheduleController.getExportScheduleItemsFieldSet";
// imported to show toast messages
import { ShowToastEvent } from "lightning/platformShowToastEvent";

// datatable columns
const cols = [];

export default class ExportDataToCSVInLWC extends LightningElement {
  @track error;
  @track data;
  @track columns = cols;
  @api recordId;
  @api invoke() {
    this.getProductionScheduleItems();
  }

  getExportScheduleItemsFieldSet() {
    getExportScheduleItemsFieldSet()
      .then((result) => {
        console.log(result);
        result.forEach((item) => {
          this.cols.add({
            label: item.sObjectName,
            fieldName: item.sObjectName
          });
        });
        console.log(this.cols);

        getProductionScheduleItems();
      })
      .catch((error) => {
        this.error = error;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error while getting Production Schedule Items",
            message: error.message,
            variant: "error"
          })
        );
        this.data = undefined;
      });
  }

  // fetching production schedule itmes from server
  getProductionScheduleItems() {
    getProductionScheduleItems({ recordId: this.recordId })
      .then((result) => {
        this.data = result;
        this.error = undefined;
        this.downloadCSVFile();
      })
      .catch((error) => {
        this.error = error;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error while getting Production Schedule Items",
            message: error.message,
            variant: "error"
          })
        );
        this.data = undefined;
      });
  }

  // this method validates the data and creates the csv file to download
  downloadCSVFile() {
    let rowEnd = "\n";
    let csvString = "";
    // this set elminates the duplicates if have any duplicate keys
    let rowData = new Set();

    // getting keys from data
    this.data.forEach(function (record) {
      Object.keys(record).forEach(function (key) {
        rowData.add(key);
      });
    });

    // Array.from() method returns an Array object from any object with a length property or an iterable object.
    rowData = Array.from(rowData);

    // splitting using ','
    csvString += rowData.join(",");
    csvString += rowEnd;

    // main for loop to get the data based on key value
    for (let i = 0; i < this.data.length; i++) {
      let colValue = 0;

      // validating keys in data
      for (let key in rowData) {
        // eslint-disable-next-line no-prototype-builtins
        if (rowData.hasOwnProperty(key)) {
          // Key value
          // Ex: Id, Name
          let rowKey = rowData[key];
          // add , after every value except the first.
          if (colValue > 0) {
            csvString += ",";
          }
          // If the column is undefined, it as blank in the CSV file.
          let value =
            this.data[i][rowKey] === undefined ? "" : this.data[i][rowKey];
          csvString += '"' + value + '"';
          colValue++;
        }
      }
      csvString += rowEnd;
    }

    // Creating anchor element to download
    let downloadElement = document.createElement("a");

    // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
    downloadElement.href =
      "data:text/csv;charset=utf-8," + encodeURI(csvString);
    downloadElement.target = "_self";
    // CSV File Name
    downloadElement.download = "ScheduleItemExport.csv";
    // below statement is required if you are using firefox browser
    document.body.appendChild(downloadElement);
    // click() Javascript function to download CSV file
    downloadElement.click();
  }
}
