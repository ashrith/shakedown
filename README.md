SHAKEDOWN

This is a Hadoop stress testing framework that utilizes Tessera (previously RHIPE), R and Whurr.. 
The cluster build code uses the same code that exists in Whurr. Here the only difference is that the cluster is stress tested by introducing periodic failures. 

The stress test of Hadoop is minimally interactive. Therefore an IDE or a interactive prompt is required. Therefore run the code as follows
'$ python -i whurr.py' 

And change your failure periodicty as required in whurr.py

Wait for the entire stack to be loaded. And then instantiated Tessera as follows

1. Login to the Namenode
2. Run your R session
3. Load the Rhipe library
4. Instantiate the Rhipe library
5. Now change the current working directory on the HDFS to "/tmp/bin" as follow > hdfs.setwd("/tmp/bin")
6. Now Run bashRhipeArchive() to enable the R library to be loaded to the distributed cache. 
	> bashRhipeArchive("RhipeLib",T)
7. After this is run, remove the comments in your .Rprofile, rerun R and your are good to go. 
8. Now you can load the runcode.R file as > source("runcode.R") 

The design of this failure test is a bit asynchronous so please run the code from a controller machine. A controller machine is a machine that runs the entire test for you, for example, an AWS instance. 

The Python framework instantiates nodes, and also fails them. The R generates the data and runs logistic regression on them. Python runs the failure only when R is running the logistic regression and not while the data is being generated. For this to happen, Python needs to know when R is running the logistic regression code. As Python and R sessions are decoupled the message has to be passed out of the loop and that is done using a "file touch" as follows from the R program. 

system("ssh -qt -o StrictHostKeyChecking=no -i amazon-key-name ubuntu@controller-pc 'touch /home/ubuntu/logistic.txt'")

For this to work, you should have uploaded your amazon-aws-key to the controller instance on AWS and also replace the controller-pc with the actual address of the controller. Please ensure that port 22 is open. 

After the logistic regression is run the following code removes the "touched file" to run the next set of values. 

system("ssh -qt -o StrictHostKeyChecking=no -i amazon-key-name ubuntu@controller-pc 'rm /home/ubuntu/logistic.txt'")

The data will be saved at the end of the test. 

In case you have any questions on this test please do let me know. Thank you. 
