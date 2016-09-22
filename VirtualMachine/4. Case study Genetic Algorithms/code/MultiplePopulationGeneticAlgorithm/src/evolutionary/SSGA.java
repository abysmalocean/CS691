package evolutionary;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Random;

public class SSGA {
	
	private Random randGen;
	
	private ArrayList<Individual> population;
	private SelectorNAM selector;
	private CrossoverBLX crossover;
	private MutatorBGA mutator;
	private Evaluator evaluator;
	
	private int populationSize;
	private int numberDimensions;
	private double domainMinValue, domainMaxValue;

	public SSGA(long seed, int populationSize, int numberDimensions)
	{
		this.randGen = new Random(seed);
		this.populationSize = populationSize;
		this.numberDimensions = numberDimensions;
		
		this.domainMinValue = -100;
		this.domainMaxValue =  100;
		this.selector = new SelectorNAM(randGen, 3);
		this.crossover = new CrossoverBLX(randGen, 0.5, domainMinValue, domainMaxValue);
		this.mutator = new MutatorBGA(randGen, 0.125, domainMinValue, domainMaxValue);
		this.evaluator = new Evaluator();
	}
	
	public ArrayList<Individual> getPopulation() {
		return population;
	}
	
	public Evaluator getEvaluator() {
		return evaluator;
	}
	
	public void initializePopulation()
	{
		population = new ArrayList<Individual>();
		
		for(int i = 0; i < populationSize; i++)
		{
			double[] genotype= new double[numberDimensions];
			
			for (int j = 0; j < numberDimensions; j++)
				genotype[j] = (domainMinValue + (randGen.nextDouble() * (domainMaxValue - domainMinValue)));
			
			population.add(new Individual(genotype));
		}
		
		evaluator.evaluate(population);
		
		Collections.sort(population, evaluator.getComparator());
	}
	
	public void runSSGA(int SSGAIterations)
	{
		for(int iteration = 0; iteration < SSGAIterations; iteration++)
		{
			// Select two parents
			ArrayList<Individual> parents = selector.select(population);

			// Recombine their genotype and generate a child
			Individual crossed = crossover.cross(parents.get(0), parents.get(1));
			// Mutate the solution
			Individual mutated = mutator.mutate(crossed);
			// Evaluate the fitness of the new solution
			evaluator.evaluate(mutated);
			// Update the population considering the new solution
			updatePopulation(mutated);
			
			if(iteration % 100 == 0)
				System.out.println("Iteration: " + iteration + " best " + population.get(0));
		}
	}

	public void updatePopulation(Individual newIndividual)
	{
		// Add the new individual to the population if not already included
		if(!population.contains(newIndividual))
		{
			population.add(newIndividual);
			// Sort population by fitness
			Collections.sort(population, evaluator.getComparator());
			// Remove the worst element (to keep populationSize constant)
			population.remove(populationSize);
		}
	}
}