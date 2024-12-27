import os
import re
import csv

# Intensity weights for operations
intensity_weights = {
    "SUM": 1,
    "AVG": 2,
    "COUNT": 1,
    "JOIN": 5,
    "GROUP BY": 2,
    "HAVING": 3,
    "ORDER BY": 4,
    "SUBQUERY": 6,
    "TABLES": 6,
    "INTERSECT": 6,
    "UNION": 6,
    "EXCEPT": 3,
    "OVER": 5,
    "DISTINCT": 4,
    "CASE WHEN": 3
}

# Regular expressions to detect SQL operations
regex_patterns = {
    "SUM": r"\bSUM\s*\(",
    "AVG": r"\bAVG\s*\(",
    "COUNT": r"\bCOUNT\s*\(",
    "JOIN": r"\bJOIN\b",
    "GROUP BY": r"\bGROUP\s+BY\b",
    "HAVING": r"\bHAVING\b",
    "ORDER BY": r"\bORDER\s+BY\b",
    "SUBQUERY": r"\(\s*SELECT",
    "TABLES": r"\bFROM\s+((?:[\w]+\s*,\s*)*[\w]+)",
    "INTERSECT": r"\bINTERSECT\b",
    "UNION": r"\bUNION\b",
    "EXCEPT": r"\bEXCEPT\b",
    "OVER": r"\bOVER\s*\(",
    "DISTINCT": r"\bDISTINCT\b",
    "CASE WHEN": r"\bCASE\b.*?\bWHEN\b"
}

def process_query(file_path):
    """Process a single query file to calculate its score."""
    with open(file_path, 'r') as file:
        content = file.read()

    # Initialize operation counts
    operation_counts = {key: 0 for key in regex_patterns.keys()}

    # Detect operations using regex
    for operation, pattern in regex_patterns.items():
        if operation == "TABLES":
            matches = re.findall(pattern, content, re.IGNORECASE)
            tables = set()
            for match in matches:
                tables.update(map(str.strip, match.split(',')))
            operation_counts["TABLES"] = len(tables)  # Unique tables per query
        else:
            operation_counts[operation] = len(re.findall(pattern, content, re.IGNORECASE))

    # Calculate the query score
    score = sum(intensity_weights[op] * count for op, count in operation_counts.items())

    return operation_counts, score

def main():
    # Directory containing .tpl files
    query_dir = r"C:\Users\koust\ECE\9th_Semester\SystemAnalysis\ntua-Analysis-and-Design-of-Information-Systems\data\DSGen-software-code-3.2.0rc1\query_templates"
    output_file = r"C:\Users\koust\ECE\9th_Semester\SystemAnalysis\ntua-Analysis-and-Design-of-Information-Systems\data\DSGen-software-code-3.2.0rc1\query_templates\query_scores.csv"

    results = []
    for filename in os.listdir(query_dir):
        if filename.endswith(".tpl") and filename.startswith("query"):
            file_path = os.path.join(query_dir, filename)
            operation_counts, score = process_query(file_path)
            results.append({"Query": filename, **operation_counts, "Score": score})

    # Write results to a CSV file
    with open(output_file, "w", newline='') as csvfile:
        fieldnames = ["Query"] + list(regex_patterns.keys()) + ["Score"]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(results)

    print(f"Results saved to {output_file}")

if __name__ == "__main__":
    main()
