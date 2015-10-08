
#############################################

reduce.count.list <- list(256,512,1024)
for (reduce.count in reduce.count.list){

library(digest)

dir.ex <-  '/user/ubuntu/experiment/'
system({paste("hadoop fs -mkdir -p ", dir.ex,sep="")})
ofolder <- paste(dir.ex,"rd.ct",reduce.count,sep="")


t2r <- list()
t2r$setup <- expression({
                        library(digest)
        })
t2r$map <- expression({
        lapply(seq_along(map.values), function(r){
                set.seed(map.values[[r]])
                value <- matrix(c(rnorm(16*63), sample(c(0,1), 16, replace=TRUE)), ncol=64)
                dvalue <- digest(value,"md5")
                rhcollect(c(map.values[[r]],dvalue),value)
        })
})

t2r$input <- 2^18
t2r$output <- ofolder
t2r$mapred <- list(mapred.task.timeout = 0
                 , mapred.reduce.tasks = reduce.count
                , mapred.reduce.slowstart.completed.maps = 0.80
)
t2r$readback <- FALSE
t2r$jobname <- t2r$ofolder
t2r.mr.time <- as.numeric(system.time(do.call("rhwatch", t2r)))

Sys.sleep(time=120)
system("ssh -qt -o StrictHostKeyChecking=no -i amazon-key-name ubuntu@controller-pc 'touch /home/ubuntu/logistic.txt'")

dir.ex <-  '/user/ubuntu/experiment_results/'
dir.in <-  '/user/ubuntu/experiment/'

#system({paste("hadoop fs -mkdir -p ", dir.ex,sep="")})
system({paste("hadoop fs -mkdir -p ", dir.in,sep="")})

ifolder <- paste(dir.in,"rd.ct",reduce.count,sep="")
ofolder <- paste(dir.ex,"rd.ct",reduce.count,sep="")

library(digest)

t2r <- list()
t2r$setup <- expression({
			library(digest)
			})

t2r$map <- expression({
		lapply(seq_along(map.values), function(r){
			v <- map.values[[r]]
			k <- map.keys[[r]]
			ini.dvalue <- digest(v,"md5")
			value <- glm.fit(v[,1:63],v[,64],family=binomial())$coef
			fin.dvalue <- digest(v,"md5")
		if(ini.dvalue == k[2])
		{
			rhcollect(k[1]%%reduce.count,1)
		}
	})
	})


t2r$reduce <- expression(
	pre = {
		total <- 0
		},
	reduce = {
		total <- sum(total,unlist(reduce.values))
		},
	post = {
		rhollect(reduce.key,total)
		}
	)

t2r$input <- ifolder
t2r$output <- ofolder
t2r$mapred <- list(mapred.task.timeout = 0
                 , mapred.reduce.tasks = reduce.count
                , mapred.reduce.slowstart.completed.maps = 0.80
)
t2r$readback <- FALSE
t2r$jobname <- t2r$ofolder
t2r.mr.time <- as.numeric(system.time(do.call("rhwatch", t2r)))
Sys.sleep(time=120)
a <- rhread(ofolder)
sink(paste(reduce.count,".txt",sep=""))
print(a[[1]][[2]])
print(t2r.mr.time)
sink()
system("ssh -qt -o StrictHostKeyChecking=no -i amazon-key-name ubuntu@controller-pc 'rm /home/ubuntu/logistic.txt'")
}
