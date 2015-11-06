class Arrays extends Object;

static function uniqueInsert(out array<string> list, string key) {
    local int low, high, mid;

    if (list.Length == 0) {
        list.AddItem(key);
        return;
    }

    low= 0;
    high= list.Length - 1;
    mid= -1;

    while(low <= high) {
        mid= (low+high)/2;
        if (list[mid] < key) {
            low= mid + 1;
        } else if (list[mid] > key) {
            high= mid - 1;
        } else {
            break;
        }
    }
    if (low > high) {
        list.InsertItem(low, key);
    }
}
