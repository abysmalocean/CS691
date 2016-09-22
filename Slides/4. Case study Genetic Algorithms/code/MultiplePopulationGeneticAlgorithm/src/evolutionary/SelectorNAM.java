package evolutionary;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Random;

public class SelectorNAM {

	private Random randGen;
	private int selectCandidates;
	
	public SelectorNAM(Random randGen, int selectCandidates)
	{
		this.randGen = randGen;
		this.selectCandidates = selectCandidates;
	}
	
	public ArrayList<Individual> select(ArrayList<Individual> population)
	{
		int populationSize = population.size();

		int parent1 = randGen.nextInt(populationSize);
		int parent2 = -1;

		double distance, maxDistance = -Double.MAX_VALUE;
		
		ArrayList<Integer> candidates = new ArrayList<Integer>();
		
		for(int i = 0; i < populationSize; i++)
			if(i != parent1)
				candidates.add(i);

		for(int i = 0; i < selectCandidates; i++)
		{
			int candidate = candidates.remove(randGen.nextInt(candidates.size()));
			
			distance = distance(population.get(parent1).getGenotype(), population.get(candidate).getGenotype());

			if(distance > maxDistance)
			{
				maxDistance = distance;
				parent2 = candidate;
			}
		}

		return new ArrayList<Individual>(Arrays.asList(population.get(parent1), population.get(parent2)));
	}
	
	private double distance(double[] individual1, double[] individual2)
	{
		assert(individual1.length == individual2.length);

		int length = individual1.length;
		double distance = 0;

		for(int i = 0; i < length; i++)
			distance += (individual1[i] - individual2[i]) * (individual1[i] - individual2[i]);

		return Math.sqrt(distance);
	}
}
