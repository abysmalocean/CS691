package Hadoop.FrequentPatternMining;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapred.MapReduceBase;
import org.apache.hadoop.mapred.Mapper;
import org.apache.hadoop.mapred.OutputCollector;
import org.apache.hadoop.mapred.Reporter;

public class AssociationRulesMapper extends MapReduceBase implements Mapper<LongWritable, Text, Text, Text> {

	private Text itemset = new Text();
	private Text val = new Text();

	public void map(LongWritable key, Text value, OutputCollector<Text, Text> im_output, Reporter reporter) throws IOException {

		String[] valueSplit = value.toString().split("\\t");

		itemset.set(valueSplit[0].replaceAll(" ", ""));	//[1,2,3]
		val.set("0;" + valueSplit[1]); //2

		//original itemset
		im_output.collect(itemset, val);

		String[] items = valueSplit[0].replace("[", "").replace("]", "").split(",");

		if(items.length > 1){

			List<String> subitemsets = getItemSets(items);

			for(String itmset : subitemsets){

				itemset.set(itmset.replaceAll(" ", ""));
				val.set(valueSplit[0] + ";" + valueSplit[1]);
				im_output.collect(itemset, val);
			}
		}
	}

	//generate powersets of exactly n-1 size
	private List<String> getItemSets(String[] items) {

		List<String> itemsets = new ArrayList<String>();		
		int n = items.length;			
		int[] masks = new int[n];

		for (int i = 0; i < n; i++)
			masks[i] = (1 << i);

		for (int i = 0; i < (1 << n); i++){				
			List<String> newList = new ArrayList<String>(n);
			for (int j = 0; j < n; j++){
				if ((masks[j] & i) != 0){
					newList.add(items[j]);
				}

				if(j == n-1 && newList.size() == n-1){	              		
					itemsets.add(newList.toString());
				}
			}				
		} 

		return itemsets;
	}
}
