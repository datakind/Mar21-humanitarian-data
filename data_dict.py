import requests
from bs4 import BeautifulSoup
import pandas as pd

def get_data_dictionary(data_name: str) -> pd.DataFrame:
    """
    Simple function to grab the data dictionary given the World Bank url for the 
    the data dictionary. 
    
    NOT VERIFIED ON ALL TABLES
    
    Update: Input is just the name of the file withou ".csv". Output is the same
    """
    #Search for page
    page = requests.get('https://microdata.worldbank.org/index.php/catalog/3823/data-dictionary')
    soup = BeautifulSoup(page.text, 'html.parser')
    lis = soup.find_all("li", {"class": "nada-list-group-item"})
    for i in range(1, len(lis)-1):
        if data_name in lis[i].find_all('a')[0].text:
            url = lis[i].find_all('a')[0].attrs['href']
            break
    
    #Grab the page
    page = requests.get(url)
    soup = BeautifulSoup(page.text, 'html.parser')
    mydivs = soup.find_all("div", {"class": "table-variable-list"})
    
    #Now build the data dictionary
    data_dictionary = []
    for row in mydivs[0].find_all('div', {"class": 'var-row'}):
        col_data = [i.text.strip() for i in row.find_all('a')]
        data_dictionary.append(col_data)
    data_dictionary_df = pd.DataFrame(data_dictionary, columns=['label', 'desc'])
    return data_dictionary_df



