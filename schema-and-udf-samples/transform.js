function transform(line) {
    var values = line.split(',');

    var obj = new Object();
    obj.Member_ID = values[0];
    obj.First_Name = values[1];
    obj.Attendance = values[2];
    obj.Department = values[3];
    obj.Date = values[4];
    var jsonString = JSON.stringify(obj);

    return jsonString;
}