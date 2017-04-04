import arff
import numpy as np
import csv
import pandas as pd
import matplotlib.pyplot as plt
import time
from collections import OrderedDict
from scipy.io.arff import loadarff

from sklearn import metrics
from sklearn.metrics import accuracy_score
from sklearn.cross_validation import train_test_split

from sklearn import svm, preprocessing
from sklearn.svm import SVC
from sklearn.tree import tree, DecisionTreeClassifier
from sklearn.metrics import roc_curve, auc, confusion_matrix
from sklearn.ensemble import RandomForestClassifier, BaggingClassifier, RandomForestRegressor, ExtraTreesClassifier, AdaBoostClassifier
from sklearn.datasets import make_classification
from sklearn.neighbors import KNeighborsClassifier
from sklearn.multiclass import OneVsRestClassifier
from sklearn.naive_bayes import GaussianNB
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
from sklearn.discriminant_analysis import QuadraticDiscriminantAnalysis
import csv


# Number of times which each classifier is run with each dataset 
num_executions = 1

# List of dataset to train ML classifiers
files = ['datasetSklearn_0.98sparse_all_features_non_none_descriptions.csv']


csv_output_file = open('resultsClassifiersSklearn.csv', 'w')
csv_output = csv.writer(csv_output_file)
data_output = [['File','Classifier', 'Acc', 'TP', 'FN', 'FP', 'TN']]


names = ["Random Forest", "Nearest Neighbors", "Decision Tree", "AdaBoost", "Naive Bayes","Bagging"]

classifiers = [
	RandomForestClassifier(n_estimators=100),
	KNeighborsClassifier(),
	DecisionTreeClassifier(),
	AdaBoostClassifier(),
	GaussianNB(),
	BaggingClassifier(RandomForestClassifier(n_estimators=100))]



for file_name in files:
	csv_roc_file = open('ROC_curve_' + file_name, 'w')
	csv_roc = csv.writer(csv_roc_file)
	data_csv_roc = [['CLS', 'FPR', 'TPR', 'THR']]

	print "Reading file: " + file_name
	df = pd.read_csv(file_name, low_memory=False)
	print "File in memory\n"

	original_headers = list(df.columns.values)


	total_data = df[original_headers[:-1]]
	total_data = total_data.as_matrix()
	target_strings = df[original_headers[-1]]



	train, test, target_train, target_test = train_test_split(total_data, target_strings, test_size=0.33, random_state=int(time.time()))


	for index, cls in enumerate(classifiers):
		for num_ex in range(0, num_executions):
			print "Execution " + str(num_ex)
			print "Training " + names[index]
			cls.fit(train, target_train)

			test_prediction = cls.predict(test)
			test_prediction_prob = cls.predict_proba(test)

			prob_max = test_prediction_prob[:,1]

			print "Classifier: " + names[index] + " - ACC: ",
			accuracy = accuracy_score(target_test, test_prediction)
			print accuracy
			conf_matrix = confusion_matrix(target_test, test_prediction)

			target_test_array = pd.np.array(target_test)-1

			total_sam = conf_matrix[0][0] + conf_matrix[0][1] + conf_matrix[1][0] + conf_matrix[1][1]


			false_positive_rate, true_positive_rate, thresholds = roc_curve(target_test_array, prob_max)


			data_line = [file_name, names[index], accuracy, conf_matrix[0][0], conf_matrix[0][1], conf_matrix[1][0], conf_matrix[1][1]]


			data_output.append(data_line)

			if num_ex == 0:

				for x in range(0, len(false_positive_rate)):
					data_csv_roc.append([names[index],false_positive_rate[x], true_positive_rate[x], thresholds[x]])


	csv_roc.writerows(data_csv_roc)
	csv_roc_file.close()

csv_output.writerows(data_output)
csv_output_file.close()
