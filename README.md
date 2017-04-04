# ADROIT

ADROIT is an Android malware detection tool which uses meta-information to train Machine Learning models

# Abstract

Android malware detection represents a current and complex problem, where black hats use different methods to infect users’ devices. One of these methods consists in directly upload malicious applications to app stores, whose filters are not always successful at detecting malware, entrusting the final user the decision of whether installing or not an application. Although there exist different solutions for analysing and detecting Android malware, these systems are far from being sufficiently precise, requiring the use of third-party antivirus software which is not always simple to use and practical. In this paper, we propose a novel method called ADROIT for analysing and detecting malicious Android applications by employing meta-information available on the app store website and also in the Android Manifest. Its main objective is to provide a fast but also accurate tool able to assist users to avoid their devices to become infected without even requiring to install the application to perform the analysis. The method is mainly based on a text mining process that is used to extract significant information from meta-data, that later is used to build efficient and highly accurate classifiers. The results delivered by the experiments performed prove the reliability of ADROIT, showing that it is capable of classifying malicious applications with 93.67% accuracy.


# Dataset

dataset.csv contains feature vectors of more than 11,000 benign and malicious Android applications. They include different information such as Manifest permissions or meta-information which can be extracted from their download page.

# Execution

ADROIT requires executing two main components:

- The text mining process, written in R
- The machile learning classification algorithms training process, written in Python

First, execute the text mining process program. The sparsity level can be adjusted in this program.

```
Rscript 1-text-mining.R
```

Second, execute Machine Learning classification algorithms using the scikit-learn Python library.

```
python 2-classification.py
```

ADROIT is described in:

Martín, A., Calleja, A., Menéndez, H. D., Tapiador, J., & Camacho, D. (2016, December). ADROIT: Android malware detection using meta-information. In Computational Intelligence (SSCI), 2016 IEEE Symposium Series on (pp. 1-8). IEEE. http://ieeexplore.ieee.org/abstract/document/7849904/


Please, if you use this software or our dataset, cite the above paper.
