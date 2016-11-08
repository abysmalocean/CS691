package Hadoop.FrequentPatternMining;

import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapred.FileInputFormat;
import org.apache.hadoop.mapred.FileOutputFormat;
import org.apache.hadoop.mapred.JobClient;
import org.apache.hadoop.mapred.JobConf;
import org.apache.hadoop.mapred.TextInputFormat;
import org.apache.hadoop.mapred.TextOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

public class AssociationRules  extends Configured implements Tool {

	public static void main(String[] args) throws Exception {
		ToolRunner.run(new AssociationRules(), args);
	}

	public int run(String[] arg0) throws Exception {

		JobConf job = new JobConf(AssociationRules.class);
		job.setJobName("Association rules computation");

		job.setOutputKeyClass(Text.class);
		job.setOutputValueClass(Text.class);

		job.setMapperClass(AssociationRulesMapper.class);
		job.setReducerClass(AssociationRulesReducer.class);

		job.setInputFormat(TextInputFormat.class);
		job.setOutputFormat(TextOutputFormat.class);
		FileInputFormat.setInputPaths(job, new Path(arg0[0]));
		FileOutputFormat.setOutputPath(job, new Path(arg0[1]));

		JobClient.runJob(job);
		
		return 0;
	}	
}