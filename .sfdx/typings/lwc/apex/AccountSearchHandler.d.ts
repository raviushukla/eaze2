declare module "@salesforce/apex/AccountSearchHandler.getAllAccounts" {
  export default function getAllAccounts(): Promise<any>;
}
declare module "@salesforce/apex/AccountSearchHandler.searchAccounts" {
  export default function searchAccounts(param: {keyword: any}): Promise<any>;
}
