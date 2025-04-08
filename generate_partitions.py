#!/usr/bin/env python3
"""
Partition Generator for Tasks Table

This script generates SQL statements for partitioning the tasks table
with both primary partitions and subpartitions.
"""

import argparse
from datetime import datetime, timedelta

def generate_tasks_partitions():
    """
    Generate SQL statements for partitioning the tasks table.
    """
    sql_statements = []
    
    # Add partitioning clause to the table definition
    sql_statements.append(
        "ALTER TABLE app.tasks PARTITION BY HASH (custom_cell_id);"
    )
    
    # Generate primary partition creation statements
    for i in range(8):
        partition_name = f"tasks_p{i}"
        sql_statements.append(
            f"CREATE TABLE app.{partition_name} PARTITION OF app.tasks "
            f"FOR VALUES WITH (MODULUS 8, REMAINDER {i});"
        )
    
    return sql_statements

def generate_tasks_subpartitions(start_year, end_year):
    """
    Generate SQL statements for subpartitioning the tasks table partitions.
    
    Args:
        start_year: The first year to create partitions for
        end_year: The last year to create partitions for
    """
    sql_statements = []
    
    # For each primary partition, create subpartitions by created_at
    for i in range(8):
        parent_partition = f"tasks_p{i}"
        
        # Add partitioning clause to the parent partition
        sql_statements.append(
            f"ALTER TABLE app.{parent_partition} PARTITION BY RANGE (created_at);"
        )
        
        # Generate monthly subpartitions for each year
        current_date = datetime(start_year, 1, 1)
        end_date = datetime(end_year, 12, 31)
        
        while current_date <= end_date:
            # Calculate end date (first day of next month)
            if current_date.month == 12:
                next_month = datetime(current_date.year + 1, 1, 1)
            else:
                next_month = datetime(current_date.year, current_date.month + 1, 1)
            
            # Format dates for SQL
            start_str = f"'{current_date.strftime('%Y-%m-%d')}'"
            end_str = f"'{next_month.strftime('%Y-%m-%d')}'"
            
            # Create subpartition name
            subpartition_name = f"{parent_partition}_{current_date.year}_{current_date.month:02d}"
            
            sql_statements.append(
                f"CREATE TABLE app.{subpartition_name} PARTITION OF app.{parent_partition} "
                f"FOR VALUES FROM ({start_str}) TO ({end_str});"
            )
            
            # Move to next month
            current_date = next_month
        
        # Add a default partition for future dates
        future_date = datetime(end_year + 1, 1, 1)
        sql_statements.append(
            f"CREATE TABLE app.{parent_partition}_future PARTITION OF app.{parent_partition} "
            f"FOR VALUES FROM ('{future_date.strftime('%Y-%m-%d')}') TO (MAXVALUE);"
        )
    
    return sql_statements

def generate_tasks_partitions_with_subpartitions(start_year, end_year):
    """
    Generate SQL statements for partitioning the tasks table with subpartitions
    in a single statement for each partition.
    
    Args:
        start_year: The first year to create partitions for
        end_year: The last year to create partitions for
    """
    sql_statements = []
    
    # Add partitioning clause to the table definition
    sql_statements.append(
        "ALTER TABLE app.tasks PARTITION BY HASH (custom_cell_id);"
    )
    
    # For each primary partition, create it with subpartitions
    for i in range(8):
        partition_name = f"tasks_p{i}"
        
        # Create the partition with subpartitioning
        sql_statements.append(
            f"CREATE TABLE app.{partition_name} PARTITION OF app.tasks "
            f"FOR VALUES WITH (MODULUS 8, REMAINDER {i}) "
            f"PARTITION BY RANGE (created_at);"
        )
        
        # Generate monthly subpartitions for each year
        current_date = datetime(start_year, 1, 1)
        end_date = datetime(end_year, 12, 31)
        
        while current_date <= end_date:
            # Calculate end date (first day of next month)
            if current_date.month == 12:
                next_month = datetime(current_date.year + 1, 1, 1)
            else:
                next_month = datetime(current_date.year, current_date.month + 1, 1)
            
            # Format dates for SQL
            start_str = f"'{current_date.strftime('%Y-%m-%d')}'"
            end_str = f"'{next_month.strftime('%Y-%m-%d')}'"
            
            # Create subpartition name
            subpartition_name = f"{partition_name}_{current_date.year}_{current_date.month:02d}"
            
            sql_statements.append(
                f"CREATE TABLE app.{subpartition_name} PARTITION OF app.{partition_name} "
                f"FOR VALUES FROM ({start_str}) TO ({end_str});"
            )
            
            # Move to next month
            current_date = next_month
        
        # Add a default partition for future dates
        future_date = datetime(end_year + 1, 1, 1)
        sql_statements.append(
            f"CREATE TABLE app.{partition_name}_future PARTITION OF app.{partition_name} "
            f"FOR VALUES FROM ('{future_date.strftime('%Y-%m-%d')}') TO (MAXVALUE);"
        )
    
    return sql_statements

def main():
    parser = argparse.ArgumentParser(description="Generate SQL for tasks table partitioning")
    parser.add_argument("--start-year", type=int, default=2023, 
                        help="Start year for subpartitions (default: 2023)")
    parser.add_argument("--end-year", type=int, default=2025, 
                        help="End year for subpartitions (default: 2025)")
    parser.add_argument("--output", default="tasks_partitions.sql", 
                        help="Output file (default: tasks_partitions.sql)")
    parser.add_argument("--format", choices=["separate", "combined"], default="combined",
                        help="Format of the SQL statements (default: combined)")
    
    args = parser.parse_args()
    
    # Generate all SQL statements
    if args.format == "separate":
        all_statements = []
        all_statements.extend(generate_tasks_partitions())
        all_statements.extend(generate_tasks_subpartitions(args.start_year, args.end_year))
    else:
        all_statements = generate_tasks_partitions_with_subpartitions(args.start_year, args.end_year)
    
    # Output the SQL statements
    output = "\n".join(all_statements)
    
    # Write to file
    with open(args.output, "w") as f:
        f.write(output)
    
    print(f"SQL statements written to {args.output}")
    print("\nPreview of generated SQL:")
    print("=" * 80)
    print(output[:500] + "...\n")
    print("=" * 80)
    print(f"Total statements: {len(all_statements)}")
    print(f"Generated partitions for years {args.start_year} to {args.end_year}")

if __name__ == "__main__":
    main() 