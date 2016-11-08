package Hadoop.FrequentPatternMining;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapred.JobConf;
import org.apache.hadoop.mapred.Partitioner;

public class FrequentItemsetPartitioner implements Partitioner<Text, IntWritable> {

	public int getPartition(Text key, IntWritable value, int numReduceTasks) {

		int keySize = key.toString().replace("[", "").replace("]", "").split(",").length;

		if(numReduceTasks == 0)
			return 0;


		if(keySize == 1)
			return 0;
		else if(keySize == 2)
			return 1;
		else
			return 2;
	}

	public void configure(JobConf arg0) {
	}
}
