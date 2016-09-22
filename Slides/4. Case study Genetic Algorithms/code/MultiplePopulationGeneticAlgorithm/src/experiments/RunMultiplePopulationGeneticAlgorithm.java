package experiments;

import java.rmi.Naming;
import java.util.ArrayList;
import java.util.Collections;

import evolutionary.Evaluator;
import evolutionary.Individual;
import remote.IRemotePopulation;

public class RunMultiplePopulationGeneticAlgorithm {

	public static void main(String[] args) throws Exception {
		
		int numberPopulations = 4;
		int localPopulationSize = 100;
		int localSSGAIterations = 1000;
		int globalIterations = 10; // total iterations = globalIterations * localSSGAIterations
		int numberDimensions = 10;
		
		Evaluator evaluator = new Evaluator();
		
		IRemotePopulation remotePopulation[] = new IRemotePopulation[numberPopulations];

		// Look registry for remote interfaces
		for(int i = 0; i < numberPopulations; i++)
			remotePopulation[i] = (IRemotePopulation) Naming.lookup("rmi://localhost/RemotePopulation" + i);
		
		// Initialize the remote populations
		for(int i = 0; i < numberPopulations; i++)
			remotePopulation[i].initializePopulation(i, localPopulationSize, numberDimensions);
		
		// Show initial best solution for each population
		for(int i = 0; i < numberPopulations; i++)
			System.out.println("Population " + i + " best initial solution " + remotePopulation[i].getBestIndividual());
		
		// Iterate a given number of global iterations
		for(int iter = 0; iter < globalIterations; iter++)
		{
			// Run the remote populations for a given number of local iterations
			for(int i = 0; i < numberPopulations; i++)
				remotePopulation[i].runSSGA(localSSGAIterations);

			// Select the best individual from each population
			ArrayList<Individual> bestIndividuals = new ArrayList<Individual>();

			for(int i = 0; i < numberPopulations; i++)
			{
				bestIndividuals.add(remotePopulation[i].getBestIndividual());
				System.out.println("Population " + i + " globalIterations " + iter + " best solution " + bestIndividuals.get(i));
			}
			
			// Sort the list of best individuals
			Collections.sort(bestIndividuals, evaluator.getComparator());
			
			// Update each remote population with the top best individual
			for(int i = 0; i < numberPopulations; i++)
				remotePopulation[i].updatePopulation(bestIndividuals.get(0));
		}
		
		// Final best solution 
		ArrayList<Individual> bestIndividuals = new ArrayList<Individual>();

		for(int i = 0; i < numberPopulations; i++)
			bestIndividuals.add(remotePopulation[i].getBestIndividual());
		
		// Sort the list of best individuals
		Collections.sort(bestIndividuals, evaluator.getComparator());
		
		System.out.println("Final best solution " + bestIndividuals.get(0));
	}
}