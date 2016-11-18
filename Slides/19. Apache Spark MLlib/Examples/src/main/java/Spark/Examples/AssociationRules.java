package Spark.Examples;

import java.util.Arrays;

import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.mllib.fpm.FPGrowth;
import org.apache.spark.mllib.fpm.FPGrowth.FreqItemset;

import org.apache.spark.SparkConf;

public class AssociationRules {

	public static void main(String[] args) {

		SparkConf sparkConf = new SparkConf().setAppName("Association Rules");
		JavaSparkContext sc = new JavaSparkContext(sparkConf);

		JavaRDD<FPGrowth.FreqItemset<String>> freqItemsets = sc.parallelize(Arrays.asList(
				new FreqItemset<String>(new String[] {"a"}, 15),
				new FreqItemset<String>(new String[] {"b"}, 35),
				new FreqItemset<String>(new String[] {"a", "b"}, 12)
				));

		org.apache.spark.mllib.fpm.AssociationRules rules = new org.apache.spark.mllib.fpm.AssociationRules().setMinConfidence(0.8);

		JavaRDD<org.apache.spark.mllib.fpm.AssociationRules.Rule<String>> results = rules.run(freqItemsets);

		for (org.apache.spark.mllib.fpm.AssociationRules.Rule<String> rule : results.collect()) {
			System.out.println(rule.javaAntecedent() + " => " + rule.javaConsequent() + ", " + rule.confidence());
		}

		sc.stop();
	}
}
