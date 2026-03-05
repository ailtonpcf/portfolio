def adjust_resources_ultralow(wildcards, attempt):
    memory_per_attempt = [5000, 10000, 20000]
    partitions         = ['short,standard,long,fat', 'short,standard,long,fat', 'short,standard,long,fat']
    duration           = ['3:00:00', '3:00:00', '3-00:00:00']
    cpus               = [1, 2, 8]
    
    # Ensure we do not exceed the number of partitions
    attempt_index = min(attempt, len(partitions)) - 1
    
    return {
        'partition': partitions[attempt_index],
        'mem_mb':    memory_per_attempt[attempt_index],
        'time':      duration[attempt_index],
        'threads':   cpus[attempt_index]
    }


def adjust_resources_low(wildcards, attempt):
    memory_per_attempt = [10000, 20000, 50000]
    partitions         = ['short,standard,long,fat', 'short,standard,long,fat', 'standard,long,fat']
    duration           = ['3:00:00', '3:00:00', '3-00:00:00']
    cpus               = [8, 16, 24]
    
    # Ensure we do not exceed the number of partitions
    attempt_index = min(attempt, len(partitions)) - 1
    
    return {
        'partition': partitions[attempt_index],
        'mem_mb':    memory_per_attempt[attempt_index],
        'time':      duration[attempt_index],
        'threads':   cpus[attempt_index]
    }



def adjust_resources_medium(wildcards, attempt):
    memory_per_attempt = [50000, 100000, 150000]
    partitions         = ['standard,long,fat', 'standard,long', 'standard,long']
    duration           = ['3-00:00:00', '3-00:00:00', '3-00:00:00']
    cpus               = [8, 16, 24]
    
    # Ensure we do not exceed the number of partitions
    attempt_index = min(attempt, len(partitions)) - 1
    
    return {
        'partition': partitions[attempt_index],
        'mem_mb':    memory_per_attempt[attempt_index],
        'time':      duration[attempt_index],
        'threads':   cpus[attempt_index]
    }



def adjust_resources_long(wildcards, attempt):
    memory_per_attempt = [150000, 200000, 240000]
    partitions         = ['long', 'long', 'long']
    duration           = ['13-00:00:00', '13-00:00:00', '13-00:00:00']
    cpus               = [42, 24, 8]
    
    # Ensure we do not exceed the number of partitions
    attempt_index = min(attempt, len(partitions)) - 1
    
    return {
        'partition': partitions[attempt_index],
        'mem_mb':    memory_per_attempt[attempt_index],
        'time':      duration[attempt_index],
        'threads':   cpus[attempt_index]
    }

def adjust_resources_medium_medium(wildcards, attempt):
    memory_per_attempt = [80000, 120000, 200000]
    partitions         = ['long,standard,fat', 'long,standard,fat', 'long,standard,fat']
    duration           = ['3-00:00:00', '3-00:00:00', '3-00:00:00']
    cpus               = [12, 16, 24]
    
    # Ensure we do not exceed the number of partitions
    attempt_index = min(attempt, len(partitions)) - 1
    
    return {
        'partition': partitions[attempt_index],
        'mem_mb':    memory_per_attempt[attempt_index],
        'time':      duration[attempt_index],
        'threads':   cpus[attempt_index]
    }

def adjust_resources_Pall_Mall(wildcards, attempt):
    memory_per_attempt = [240000, 240000, 240000]
    partitions         = ['long,standard,fat', 'long,standard,fat', 'long,standard,fat']
    duration           = ['3-00:00:00', '3-00:00:00', '3-00:00:00']
    cpus               = [48, 48, 48]
    
    # Ensure we do not exceed the number of partitions
    attempt_index = min(attempt, len(partitions)) - 1
    
    return {
        'partition': partitions[attempt_index],
        'mem_mb':    memory_per_attempt[attempt_index],
        'time':      duration[attempt_index],
        'threads':   cpus[attempt_index]
    }

def adjust_resources_fat(wildcards, attempt):
    memory_per_attempt = [500000, 1000000, 1500000]
    partitions         = ['fat', 'fat', 'fat']
    duration           = ['3-00:00:00', '3-00:00:00', '3-00:00:00']
    cpus               = [8, 12, 16]
    
    # Ensure we do not exceed the number of partitions
    attempt_index = min(attempt, len(partitions)) - 1
    
    return {
        'partition': partitions[attempt_index],
        'mem_mb':    memory_per_attempt[attempt_index],
        'time':      duration[attempt_index],
        'threads':   cpus[attempt_index]
    }

def singUrl(tool):
    return os.path.join("https://depot.galaxyproject.org/singularity", tool)