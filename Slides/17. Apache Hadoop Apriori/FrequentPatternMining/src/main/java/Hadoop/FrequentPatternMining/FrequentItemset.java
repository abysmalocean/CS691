package Hadoop.FrequentPatternMining;

import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapred.FileInputFormat;
import org.apache.hadoop.mapred.FileOutputFormat;
import org.apache.hadoop.mapred.JobClient;
import org.apache.hadoop.mapred.JobConf;
import org.apache.hadoop.mapred.TextInputFormat;
import org.apache.hadoop.mapred.TextOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

public class FrequentItemset  extends Configured implements Tool {

	public static void main(String[] args) throws Exception {
		ToolRunner.run(new FrequentItemset(), args);
	}

	public int run(String[] arg0) throws Exception {

		JobConf job = new JobConf(FrequentItemset.class);
		job.setJobName("Frequent itemset generation");

		job.setOutputKeyClass(Text.class);
		job.setOutputValueClass(IntWritable.class);

		job.setMapperClass(FrequentItemsetMapper.class);
		job.setReducerClass(FrequentItemsetReducer.class);
		job.setPartitionerClass(FrequentItemsetPartitioner.class);

		job.setNumReduceTasks(4); //Each for itemsets of size 1, 2 and 3 

		job.setInputFormat(TextInputFormat.class);
		job.setOutputFormat(TextOutputFormat.class);
		FileInputFormat.setInputPaths(job, new Path(arg0[0]));
		FileOutputFormat.setOutputPath(job, new Path(arg0[1]));

		JobClient.runJob(job);
		
		return 0;
	}	
}
