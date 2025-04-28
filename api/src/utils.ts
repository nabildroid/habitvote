

export function generateVoteId(date: Date, { startHour = 0, endHour = 24, habitId = "habitID" } = {}) {
    // Extract just the date portion
    const baseDate = new Date(
        date.getFullYear(),
        date.getMonth(),
        date.getDate()
    );

    // Determine which time range this date falls into
    let rangeIndex = 0;
    const hour = date.getHours();

    if (hour >= startHour && (hour < endHour || endHour === 24)) {
        // Date is within the specified range
        rangeIndex = 0;
    } else if (endHour <= startHour) {
        // Handle ranges that cross midnight
        if (hour >= startHour || hour < endHour) {
            rangeIndex = 0;
        } else {
            rangeIndex = 1;
        }
    } else {
        // Multiple ranges in a day
        rangeIndex = Math.floor((hour - startHour) / (endHour - startHour));
    }

    // Format date as YYYYMMDD
    const year = baseDate.getFullYear();
    const month = String(baseDate.getMonth() + 1).padStart(2, '0');
    const day = String(baseDate.getDate()).padStart(2, '0');
    const dateStr = `${year}${month}${day}`;

    // Generate the original ID string
    const originalId = `${dateStr}_${rangeIndex}_${startHour}_${endHour}${habitId ? `_${habitId}` : ''}`;

    // Hash the ID to make it shorter
    let hash = 0;
    for (let i = 0; i < originalId.length; i++) {
        const char = originalId.charCodeAt(i);
        hash = ((hash << 5) - hash) + char;
        hash = hash & hash; // Convert to 32bit integer
    }

    // Convert to a shorter alphanumeric representation
    const hashStr = Math.abs(hash).toString(36);
    return hashStr;
}