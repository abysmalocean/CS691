package Spark.Examples;

import org.apache.spark.api.java.*;
import org.apache.spark.SparkConf;
import org.apache.spark.api.java.function.Function;

public class CountLinesWord {
	
	public static void main(String[] args)
	{
		String inputfile = args[0];
		SparkConf conf = new SparkConf().setAppName("Count lines with a given word");
		JavaSparkContext sc = new JavaSparkContext(conf);
		JavaRDD<String> data = sc.textFile(inputfile).cache();

		long numLines1 = data.filter(new Function<String, Boolean>() {
			public Boolean call(String s) { return s.contains("sit"); }
		}).count();

		long numLines2 = data.filter(new Function<String, Boolean>() {
			public Boolean call(String s) { return s.contains("urna"); }
		}).count();

		System.out.println("Lines with sit: " + numLines1 + ", lines with urna: " + numLines2);
	}
}

