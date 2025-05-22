declare module "@salesforce/apex/AccountAndProductSearchController.getAllAccounts" {
  export default function getAllAccounts(): Promise<any>;
}
declare module "@salesforce/apex/AccountAndProductSearchController.searchAccounts" {
  export default function searchAccounts(param: {keyword: any}): Promise<any>;
}
