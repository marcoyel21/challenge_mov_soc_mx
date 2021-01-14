
#!/usr/bin/python

#Secuential Backward Feature Selection
#Nota: para la realización de estas funciones se consultó el libro de Sebastian Raschka- Python Machine Learning

from sklearn.base import clone
from itertools import combinations
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
import matplotlib.pyplot as plt
#A nuestra clase la vamos alimnetar con una base de datos previamente dividida en train y test sets


#from sklearn.model_selection import train_test_split
#X, y = df.iloc[:, 1:].values, df.iloc[:, 0].values
#X_train, X_test, y_train, y_test = \
#train_test_split(X, y, test_size=0.3, random_state=0)

#Se recomienda escalar los datos
#from sklearn.preprocessing import MinMaxScaler
#mms = MinMaxScaler()
#X_train_norm = mms.fit_transform(X_train)
#X_test_norm = mms.transform(X_test)

#from sklearn.preprocessing import StandardScaler
#stdsc = StandardScaler()
#X_train_std = stdsc.fit_transform(X_train)
#X_test_std = stdsc.transform(X_test)

class SBS():
 def __init__(self, estimator, k_features,
    scoring=accuracy_score,
    test_size=0.25, random_state=1):
    self.scoring = scoring
    self.estimator = clone(estimator)
    self.k_features = k_features
    self.test_size = test_size
    self.random_state = random_state

# Definimos k_features a el número objetivo de variables deseadas
# Asimismo llamamos a las herramientas necesarias para medir el accuracy para cada tipo de modelo


 def fit(self, X, y):
    X_train, X_test, y_train, y_test = \
       train_test_split(X, y, test_size= self.test_size,
          random_state=self.random_state)

#En segundo lugar dividimos la muestra para hacer cross validation

    dim = X_train.shape[1]
    self.indices_ = tuple(range(dim))
    self.subsets_ = [self.indices_]
    score = self._calc_score(X_train, y_train,
                 X_test, y_test, self.indices_)
    self.scores_ = [score]

#En tercer lugar realizamos la reducción de dimensionalidad
# self.scores guuarda el accuracy de cada iteración
# la columan indices del ultimo subset es asignada a self.indices que podemos usar para transformar la base de datos ahora con solo k variables.


    while dim > self.k_features:
        scores = []
        subsets = []

        for p in combinations(self.indices_, r=dim-1):
            score = self._calc_score(X_train, y_train,
            X_test, y_test, p)
        scores.append(score)
        subsets.append(p)

        best = np.argmax(scores)
        self.indices_ = subsets[best]
        self.subsets_.append(self.indices_)
        dim -= 1

        self.scores_.append(scores[best])
    self.k_score_ = self.scores_[-1]

    return self

 def transform(self, X):

    return X[:, self.indices_]

#En cuarto lugar, elegimos la combinación con el mayor score

 def _calc_score(self, X_train, y_train,
                       X_test, y_test, indices):
    self.estimator.fit(X_train[:, indices], y_train)
    y_pred = self.estimator.predict(X_test[:, indices])
    score = self.scoring(y_test, y_pred)
    return score

#Creo esta función para graficar el análisis (input=modelo,cantidad de variables objetivo)
# Grafica el accuracy vs la cantidad de k_features (variables)

def graf_k_feat(modelo,X,y):

    sbs = SBS(modelo, 1)
    sbs.fit(X, y)
    k_feat = [len(k) for k in sbs.subsets_]
    plt.plot(k_feat, sbs.scores_, marker='o')
    plt.ylim([0.0, 1.1])
    plt.ylabel('Accuracy')
    plt.xlabel('Variables')
    plt.grid()
    return plt.show()

#Por ultimo creo esta función para que me indique cuáles son las variables que debo dejar indicando cuantas k quisiera quitar
def nombres_variables(modelo,cantidad_k_omitidas,df,X,y):
    sbs = SBS(modelo, 1)
    sbs.fit(X, y)
    k5 = list(sbs.subsets_[cantidad_k_omitidas])
    print(df.columns[1:][k5])


### Feature Selection (low variability)

def iqr(df):
    q3 = df.quantile(.75)
    q1 = df.quantile(.25)
    iqr = q3 - q1
    return iqr

def low_var(df):
    """
    inputs:        dataframe
    outputs:       dataframe eliminando las variables con menos variabilidad, pueden ser aquellas con
                   un rango intercuartilico menor al global o una fracción de éste
    numercic_df:   se toman unicamente las variables numéricas
    normalized_df: se normalizan las varibles
    columnlist:    se toma el nombre de las columnas (es una variable intermedia para 
                   concatenar toda la base y obtener valores globales)
    global_base:   es la base concatenada para obtner el rango intercuartilico global.
    iqr_cap:       es la quinta parte del rango intercuartilico global, se puede jugar con el valor
    low_var:       es el dataframe que filtra las bases que aportan poca variabilidad
    """
    numeric_df =  df.select_dtypes(include=['int64','float64'])
    normalized_df = (numeric_df-numeric_df.mean())/numeric_df.std()
    columnlist = normalized_df.columns
    global_base = pd.concat(map(normalized_df.get,columnlist))
    iqr_cap = (iqr(global_base)) #.2 Para verificar fucionalidad  no se realiza la multiplicación pero se recomienda tomar como threshold 1/5 de la IQR global
    low_var = numeric_df.drop(columns=numeric_df.columns[(iqr(numeric_df)< iqr_cap)],axis=1)
    return low_var

### Correlation Filtering

def drop_corralated(df):
    """
    inputs: dataframe
    output: dataframe
    numeric_df: selecciona unucamente variables numéricas
    corr_matrix: obtiene matriz de correlaciones
    upper: nos da el triangulo superior de la matriz de corr_matrix
    to_drop: función que elimina todos aquellas variables mayores a nivel de correlación determinado
    drop_correlated: elimina del dataframe una de las varibles correlacionadas
    """
    numeric_df =  df.select_dtypes(include=['int64','float64'])
    corr_matrix = numeric_df.corr().abs()
    upper = corr_matrix.where(np.triu(np.ones(corr_matrix.shape), k=1).astype(np.bool))
    to_drop = [column for column in upper.columns if any(upper[column] > 0.5)]
    drop_correlated = numeric_df[numeric_df.columns.difference(to_drop)]
    return drop_correlated


def fast(df):
    """
    input:dataframe
    output:dataframe
    numeric_df:selecciona variable numéricas
    corr_matrix: obtiene matriz de correlaciones
    var_corr: obtiene correlación entre variable objetivo y el resto en forma ascendente
    index: transforma nombre de variables de var_corr en u índice
    a_list: transforma índice con el nombre de las variables en orden ascendente en lista
    to_keep: lista de variables que tienen un cierto nivel de correlación con la variable objetivo
    kee_df: me entrega el dataframe con las variables que quiero mantener
    corr_matrix: obtiene matriz de correlación de las variables que quiero mantener
    upper: obtengo triangulo superior de la matriz de correlación
    to_drop: lista de variables con un nivel de correlación alto entre ellas
    drop_correlated: elimina de la base original la lista de variables to_drop
    Se entrega dataframe con variables seleccionadas
    
    """
    numeric_df =  df.select_dtypes(include=['int64','float64'])
    corr_matrix = numeric_df.corr().abs()
    var_corr = corr_matrix['class'].sort_values(ascending=False)
    index = var_corr.index
    a_list = list(index)
    to_keep = [a_list[i] for i in range(0, len(var_corr)) if np.abs(var_corr[i])> 0.3 and #Se usa 3 para verificar fucionalidad pero el valor debería ser por encima de .5
               np.abs(var_corr[i]) != 1]
    keep_df = numeric_df[to_keep]
    corr_matrix = keep_df.corr().abs()
    upper = corr_matrix.where(np.triu(np.ones(corr_matrix.shape), k=1).astype(np.bool))
    to_drop = [column for column in upper.columns if any(upper[column] > 0.3)] #Se usa .3 para verificar funcionalidad
    drop_correlated = numeric_df[numeric_df.columns.difference(to_drop)]
    return drop_correlated
