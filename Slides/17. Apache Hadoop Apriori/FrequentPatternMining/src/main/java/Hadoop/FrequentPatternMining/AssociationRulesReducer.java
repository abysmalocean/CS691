package Hadoop.FrequentPatternMining;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

import org.apache.hadoop.io.FloatWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapred.MapReduceBase;
import org.apache.hadoop.mapred.OutputCollector;
import org.apache.hadoop.mapred.Reducer;
import org.apache.hadoop.mapred.Reporter;

public class AssociationRulesReducer extends MapReduceBase implements Reducer<Text, Text, Text, FloatWritable> {
		
	public void reduce(Text key, Iterator<Text> values, OutputCollector<Text, FloatWritable> output, Reporter reporter) throws IOException {
	
		int keyCount = 0;
		HashMap<String,Integer> hashMap = new HashMap<String,Integer>();
	
		String[] keyitems = key.toString().replace("[", "").replace("]", "").split(",");
		      
		while (values.hasNext()) {
	
			String val = values.next().toString();
			String[] valuesplit = val.split(";");   //[1,2,3];0 OR 0;1
		
				if(valuesplit[0].equals("0")){	       			
					keyCount = Integer.parseInt(valuesplit[1]);
				}
				else{
					String[] parentItems = valuesplit[0].replace("[", "").replace("]", "").split(",");
					hashMap.put(key + " -> " + getSeparateItem(parentItems,keyitems),  Integer.parseInt(valuesplit[1]));
				}	       		
		}
	
		Iterator<String> iterator = hashMap.keySet().iterator();
	   
		while(iterator.hasNext()){
			String k = iterator.next().toString();
			int v = hashMap.get(k);
		
			output.collect(new Text(k.replace("[", "{").replace("]", "}")), new FloatWritable(v/(float)keyCount));
		}	
	}
	
	private String getSeparateItem(String[] parentItems, String[] keyitems) {
	
		String item = null;
		List<String> items = Arrays.asList(keyitems);
	
		for(String s : parentItems){
			if(!items.contains(s)){
				item = s;
				break;
			}
		}				
		return item;
	}			
}
