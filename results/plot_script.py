import pandas as pd
import matplotlib.pyplot as plt
import os
import numpy as np


def plot_benchmark_results_by_group(parsed_results, metric_column, ylabel, title, query_groups):
    """
    Plots benchmark results as grouped bar charts for each query group across databases.
    Also plots the sum of the metric for each query group across databases in a single figure.

    Parameters:
    - parsed_results (dict): Dictionary with database names as keys and DataFrames as values.
    - metric_column (str): The column to use for the y-axis values.
    - ylabel (str): Label for the y-axis.
    - title (str): Title of the plot.
    - query_groups (dict): A dictionary where keys are group names and values are lists of queries.
    """
    # Create the 'plots' folder if it doesn't exist
    plots_dir = os.path.join(os.getcwd(), "plots")
    os.makedirs(plots_dir, exist_ok=True)

    combined_data = []
    for db, data in parsed_results.items():
        data["database"] = db  # Add a column to identify the database
        combined_data.append(data)

    combined_df = pd.concat(combined_data)

    # Dictionary to store the sum of each query group for each database
    group_sums = {group_name: {} for group_name in query_groups.keys()}

    for group_name, queries in query_groups.items():
        group_df = combined_df[combined_df["query"].isin(queries)]

        # Pivot the data for grouped bar plotting
        pivot_df = group_df.pivot(index="query", columns="database", values=metric_column)

        # Sort the queries based on the sum of values across databases
        pivot_df["sum"] = pivot_df.sum(axis=1)
        pivot_df = pivot_df.sort_values(by="sum").drop(columns=["sum"])

        # Plot the grouped bar chart
        pivot_df.plot(kind="bar", figsize=(12, 6), width=0.8)
        plt.xlabel("Query")
        plt.ylabel(ylabel)
        plt.title(f"{title} - {group_name}")
        plt.xticks(rotation=45, ha="right")
        plt.legend(title="Database")
        plt.tight_layout()

        # Save the plot in the 'plots' folder
        plot_path = os.path.join(plots_dir, f"{title} - {group_name}.png")
        plt.savefig(plot_path)
        plt.show()

        # Calculate the sum of the metric for each database in the current group
        for db in parsed_results.keys():
            group_sums[group_name][db] = group_df[group_df["database"] == db][metric_column].sum()

    # Plot the sum of each query group across databases in a single figure
    plt.figure(figsize=(12, 6))
    databases = list(parsed_results.keys())
    x = np.arange(len(databases))  # the label locations
    width = 0.2  # the width of the bars

    # Define colors for each query group
    colors = {"Lightweight": "blue", "Midweight": "green", "Heavyweight": "red"}

    # Plot bars for each query group
    for i, (group_name, sums) in enumerate(group_sums.items()):
        plt.bar(x + i * width, [sums[db] for db in databases], width, label=group_name, color=colors[group_name])

    # Add labels, title, and legend
    plt.xlabel("Database")
    plt.ylabel(f"Total {ylabel}")
    plt.title(f"Total {metric_column} for Query Groups Across Databases")
    plt.xticks(x + width, databases)
    plt.legend(title="Query Group")
    plt.tight_layout()

    # Save the plot in the 'plots' folder
    plot_path = os.path.join(plots_dir, f"Total {metric_column} for Query Groups Across Databases.png")
    plt.savefig(plot_path)
    plt.show()


def parse_benchmark_results(file_paths, columns_to_extract):
    """
    Parses benchmark result files and extracts specific columns for given databases.

    Parameters:
    - file_paths (dict): A dictionary where keys are database names and values are file paths.
    - columns_to_extract (list): List of columns to extract.

    Returns:
    - dict: A dictionary with database names as keys and DataFrames as values.
    """
    result = {}
    for db, file_path in file_paths.items():
        try:
            # Read the input file with tab-delimited separator
            df = pd.read_csv(file_path, delim_whitespace=True)

            # Extract relevant columns
            result[db] = df[columns_to_extract]
        except Exception as e:
            print(f"Error reading file {file_path}: {e}")
    
    print(result)
    return result


if __name__ == "__main__":

    # Define input parameters
    root_path = r"C:\Users\koust\ECE\9th_Semester\SystemAnalysis\ntua-Analysis-and-Design-of-Information-Systems\results"
    file_paths_sf1 = {
        "postgresql_sf1": root_path + r"\tpcds_postgresql_sf1.txt",
        "mongo_sf1": root_path + r"\tpcds_mongodb_sf1.txt",
        "cassandra_sf1": root_path + r"\tpcds_cassandra_sf1.txt",
    }
    file_paths_sf10 = {
        "postgresql_sf10": root_path + r"\tpcds_postgresql_sf10.txt",
        "mongo_sf10": root_path + r"\tpcds_mongodb_sf10.txt",
        "cassandra_sf10": root_path + r"\tpcds_cassandra_sf10.txt",
    }
    file_paths_sf1_combined = {
        "combined_sf1": root_path + r"\tpcds_combined_sf1.txt",
        "combined_sf1_w1": root_path + r"\tpcds_combined_sf1_w1.txt",
        "combined_sf1_w2": root_path + r"\tpcds_combined_sf1_w2.txt",
    }
    file_paths_sf10_combined = {
        "combined_sf10": root_path + r"\tpcds_combined_sf10.txt",
        "combined_sf10_w1": root_path + r"\tpcds_combined_sf10_w1.txt",
        "combined_sf10_w2": root_path + r"\tpcds_combined_sf10_w2.txt",
    }

    columns_to_extract = ["query", "wallTimeMean"]

    # Parse the files
    parsed_results_sf1 = parse_benchmark_results(file_paths_sf1, columns_to_extract)
    parsed_results_sf10 = parse_benchmark_results(file_paths_sf10, columns_to_extract)
    parsed_results_sf1_combined = parse_benchmark_results(file_paths_sf1_combined, columns_to_extract)
    #parsed_results_sf10_combined = parse_benchmark_results(file_paths_sf10_combined, columns_to_extract)


    query_groups = {
        "Lightweight": ["Q65", "Q51", "Q15", "Q30", "Q1"],
        "Midweight": ["Q77", "Q35", "Q49", "Q94", "Q76"],
        "Heavyweight": ["Q39", "Q78", "Q5", "Q21"],
    }

    # Plot the results

    # For SF1
    # Plot results for wallTimeMean grouped by query type
    plot_benchmark_results_by_group(
        parsed_results_sf1,
        metric_column="wallTimeMean",
        ylabel="Time(ms)",
        title="Wall Time Mean for SF1",
        query_groups=query_groups,
    )

    # For SF10
    # Plot results for wallTimeMean grouped by query type
    plot_benchmark_results_by_group(
        parsed_results_sf10,
        metric_column="wallTimeMean",
        ylabel="Time(ms)",
        title="Wall Time Mean for SF10",
        query_groups=query_groups,
    )

    # For combined SF1
    # Plot results for walLTimeMean grouped by query type
    plot_benchmark_results_by_group(
        parsed_results_sf1_combined,
        metric_column="wallTimeMean",
        ylabel="Time(ms)",
        title="Wall Time Mean for Combined SF1",
        query_groups=query_groups,
    )